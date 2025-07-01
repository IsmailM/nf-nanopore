FROM python:3.12-alpine

RUN apk add --no-cache gcc g++ make musl-dev linux-headers bash hdf5-dev \
    && apk add --no-cache --virtual .build-deps python3-dev

# RUN pip install --no-cache-dir pod5
RUN pip install --no-cache-dir ont-fast5-api

RUN apk del .build-deps

# Create a non-root user for security
RUN adduser -D -h /app appuser
USER appuser
WORKDIR /app

# Set Python to run in unbuffered mode
ENV PYTHONUNBUFFERED=1

COPY convert_single_to_multi_fast5.sh /app/convert_single_to_multi_fast5.sh

CMD ["sh", "/app/convert_single_to_multi_fast5.sh"]
