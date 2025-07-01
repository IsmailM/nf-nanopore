FROM python:3.9-slim
# procps is needed for ps command used by nextflow
RUN apt-get update && apt-get install -y tk python3-tk procps tabix bedtools
RUN pip install --no-cache-dir modbamtools
WORKDIR /app
CMD ["modbamtools", "--help"]
