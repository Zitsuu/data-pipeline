from functools import lru_cache

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    postgres_user: str = "pipeline"
    postgres_password: str = "pipeline_dev_pw"
    postgres_db: str = "warehouse"
    postgres_host: str = "localhost"
    postgres_port: int = 5432
    github_token: str = ""
    prefect_api_url: str = "http://localhost:4200/api"

    @property
    def database_url(self) -> str:
        return (
            f"postgresql://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
