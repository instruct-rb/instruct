# Building Effective Agents Cookbook

Instruct reference implementation for [Building Effective Agents](https://anthropic.com/research/building-effective-agents) by Erik Schluntz and Barry Zhang.

For the Anthropic reference implementation in python, see [Building Effective Agents Cookbook](https://github.com/anthropics/anthropic-cookbook/blob/main/patterns/agents/README.md)

This folder contains example minimal implementations of common agent workflows discussed in the blog:

- Basic Building Blocks
  - Prompt Chaining
  - Routing
  - Multi-LLM Parallelization (coming later – awaiting async net adapter support to ruby-openai and anthropic)
- Advanced Workflows
  - Orchestrator-Subagents
  - Evaluator-Optimizer

## Getting Started
See the IRuby Jupyter notebooks for detailed examples:

- [Basic Workflows](basic_workflows.ipynb)
- ~~[Evaluator-Optimizer Workflow](evaluator_optimizer.ipynb)~~ (coming later)
- ~~[Orchestrator-Workers Workflow](orchestrator_workers.ipynb)~~ (coming later)
