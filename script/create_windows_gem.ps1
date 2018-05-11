docker build -q -f Dockerfile.windows.ci -t ruby-slim .
docker run -ti --rm -v ${PWD}:C:\stack_master -w C:\stack_master ruby-slim gem build stack_master.gemspec
