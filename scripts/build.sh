pub run build_runner build
# docker build --tag flutter_compiler:1.0 .
# docker build .
docker run -d -P --name compiler $(docker build -q .) && docker port compiler
docker port static-site