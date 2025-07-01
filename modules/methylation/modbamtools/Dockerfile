FROM python:3.9-slim
RUN apt-get update && apt-get install -y tk python3-tk
RUN pip install --no-cache-dir modbamtools
WORKDIR /app
CMD ["modbamtools", "--help"]
