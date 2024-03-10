FROM julia:alpine
COPY . /app
WORKDIR /app
CMD julia Main.jl