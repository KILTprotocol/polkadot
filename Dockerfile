# this container builds the kilt-parachain binary from source files and the runtime library
# pinned the version to avoid build cache invalidation
FROM paritytech/ci-linux:5297d82c-20201107 as builder

WORKDIR /build

# copy everything over (cache invalidation will happen here)
COPY . /build
# build source again, dependencies are already built
RUN cargo build --release --features=real-overseer

FROM debian:stretch

WORKDIR /runtime

RUN apt-get -y update && \
	apt-get install -y --no-install-recommends \
	openssl \
	curl \
	libssl-dev dnsutils

# cleanup linux dependencies
RUN apt-get autoremove -y
RUN apt-get clean -y
RUN rm -rf /tmp/* /var/tmp/*

COPY --from=builder /build/target/release/polkadot ./polkadot
COPY --from=builder /build/rococo-local-v1-raw_2-validators.json ./rococo-local-v1-raw_2-validators.json
COPY --from=builder /build/rococo-custom.json ./rococo-custom.json

# expose node ports
EXPOSE 30333 9933 9944

#
# Pass the node start command to the docker run command
#
# To start a collator:
# ./start-local-node
#
#
ENTRYPOINT ["./polkadot"]
CMD ["echo","\"Please provide a startup command.\""]
