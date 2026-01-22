from langchain_core.embeddings import Embeddings
import os

from langchain_openai import OpenAIEmbeddings
from langchain_huggingface import HuggingFaceEmbeddings

from .config import RAGConfig


def get_embedding_model(config: RAGConfig) -> Embeddings:
    """
    Returns a LangChain Embeddings object based on config.

    - embedding_provider == "openrouter":
        Uses OpenAIEmbeddings via OpenRouter (OpenAI-compatible API).

    - embedding_provider == "huggingface":
        Uses HuggingFaceEmbeddings with device forced to CPU to avoid
        issues like "Cannot copy out of meta tensor; no data!" on some setups.
    """
    if config.embedding_provider in {"openrouter", "openai"}:
        api_key = os.getenv("OPENROUTER_API_KEY")
        if not api_key:
            raise RuntimeError("OPENROUTER_API_KEY is not set.")
        return OpenAIEmbeddings(
            model=config.embedding_model_name,
            api_key=api_key,
            base_url="https://openrouter.ai/api/v1",
        )

    # Default: Hugging Face embeddings on CPU
    return HuggingFaceEmbeddings(
        model_name=config.embedding_model_name,
        model_kwargs={"device": "cpu"},           # 🔴 force CPU
        encode_kwargs={"normalize_embeddings": True}, # 🔴 normalize embeddings
    )
