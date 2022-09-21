#FROM ghcr.io/z3prover/z3:ubuntu-20.04-bare-z3-sha-660bdc3 as z3Base
#FROM ethereum/solc:0.8.17 as solcBase

FROM runtimeverificationinc/runtimeverification-evm-semantics:ubuntu-focal-master

#FROM ubuntu:20.04 as lib-base

#IENTRYPOINT ["/usr/bin/bash"]

RUN apt-get -y update \ 
	&& apt-get install -y apt-utils \
	&& apt-get install -y software-properties-common \
	&& apt-get -y update \
	&& add-apt-repository -y ppa:ethereum/ethereum \
	&& apt-get update \
	&& apt-get install -y solc
