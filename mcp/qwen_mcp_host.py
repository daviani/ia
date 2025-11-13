#!/usr/bin/env python3
"""
Bridge entre LiteLLM (Ollama/Qwen3) et des serveurs MCP.

Ce script utilise l'implémentation expérimentale `huggingface_hub.Agent`
qui repose sur le package `mcp` (Model Context Protocol).

⚠️ Dépendances supplémentaires (non installées hors-ligne) :
    python3 -m pip install --user "mcp>=1.2.0" "huggingface_hub>=0.24.0"
"""
from __future__ import annotations

import argparse
import asyncio
import os
import sys
from pathlib import Path
from typing import Iterable

from huggingface_hub import ChatCompletionInputMessage, ChatCompletionStreamOutput
from huggingface_hub.inference._mcp.agent import Agent
from huggingface_hub.inference._mcp.types import ServerConfig


def _filesystem_server(root: Path, allowed_tools: list[str] | None = None) -> ServerConfig:
    cfg: ServerConfig = {
        "type": "stdio",
        "command": "npx",
        "args": [
            "--yes",
            "@modelcontextprotocol/server-filesystem",
            str(root),
        ],
        "env": dict(os.environ),
        "cwd": str(root),
    }
    if allowed_tools:
        cfg["allowed_tools"] = allowed_tools
    return cfg


async def _interactive_loop(agent: Agent) -> None:
    print("✅ MCP host prêt. Tapez votre question (ou 'exit').")
    while True:
        try:
            user_input = input("mcp> ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nAu revoir 👋")
            return

        if not user_input:
            continue
        if user_input.lower() in {"exit", "quit", "bye"}:
            print("Au revoir 👋")
            return

        async for event in agent.run(user_input):
            if isinstance(event, ChatCompletionStreamOutput):
                delta = event.choices[0].delta if event.choices else None
                if delta and delta.content:
                    print(delta.content, end="", flush=True)
                if delta and delta.tool_calls:
                    print("")
                    for call in delta.tool_calls:
                        print(f"[tool-call] {call.function.name}({call.function.arguments})")
            elif isinstance(event, ChatCompletionInputMessage):
                role = event.role
                name = getattr(event, "name", None)
                prefix = f"[{role}]" if not name else f"[{role}:{name}]"
                print(f"\n{prefix} {event.content}\n")

        print("")


def _parse_servers(args: argparse.Namespace) -> Iterable[ServerConfig]:
    servers: list[ServerConfig] = []

    if args.filesystem_root:
        root = Path(args.filesystem_root).expanduser().resolve()
        root.mkdir(parents=True, exist_ok=True)
        servers.append(_filesystem_server(root, allowed_tools=None))

    for raw in args.extra_server:
        parts = raw.split("::", 1)
        if len(parts) != 2:
            raise ValueError(f"Format serveur invalide: {raw} (attendu type::commande)")
        srv_type, command = parts
        cmd_parts = command.split()
        servers.append({"type": srv_type, "command": cmd_parts[0], "args": cmd_parts[1:], "env": dict(os.environ), "cwd": os.getcwd()})

    if not servers:
        raise SystemExit("❌ Aucun serveur MCP n'a été fourni. Utilisez --filesystem-root ou --extra-server.")
    return servers


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Host MCP local branché sur Qwen3/Ollama via LiteLLM.")
    parser.add_argument("--litellm-url", default="http://127.0.0.1:4000/v1", help="Endpoint OpenAI-compatible (LiteLLM).")
    parser.add_argument("--api-key", default="dummy-key", help="Clé utilisée par LiteLLM (doit correspondre à general_settings.master_key).")
    parser.add_argument("--model", default="qwen3-dev", help="Alias du modèle déclaré dans litellm.config.yaml.")
    parser.add_argument("--filesystem-root", help="Chemin à exposer via le serveur MCP filesystem.")
    parser.add_argument(
        "--extra-server",
        action="append",
        default=[],
        help="Serveur supplémentaire au format type::commande (ex: stdio::\"npx -y @modelcontextprotocol/server-browser\").",
    )
    return parser.parse_args()


async def main() -> None:
    args = parse_args()
    servers = list(_parse_servers(args))
    agent = Agent(model=args.model, base_url=args.litellm_url, api_key=args.api_key, servers=servers)

    async with agent:
        await agent.load_tools()
        await _interactive_loop(agent)


if __name__ == "__main__":
    asyncio.run(main())
