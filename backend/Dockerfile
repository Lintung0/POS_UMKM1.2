FROM golang:1.23-alpine

WORKDIR /app

# Install dependencies required for some go packages like CGO if needed
RUN apk add --no-cache gcc musl-dev

# Copy module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go application
RUN go mod tidy && go build -o server .

# Expose the API port
EXPOSE 8081

# Command to run the executable
CMD ["./server"]
