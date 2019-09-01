docker build -t geoserver .
docker run -it -p 127.0.0.1:8080:8080/tcp --rm geoserver