FROM python:3.9-alpine

RUN apk add --no-cache gcc g++ make musl-dev linux-headers bash \
    && apk add --no-cache --virtual .build-deps python3-dev

RUN pip install --no-cache-dir sniffles2_plot
RUN apk del .build-deps

# Create a non-root user for security
RUN adduser -D -h /app appuser
USER appuser
WORKDIR /app
 
# Set Python to run in unbuffered mode
ENV PYTHONUNBUFFERED=1
