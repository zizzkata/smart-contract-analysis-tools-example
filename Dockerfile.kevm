FROM runtimeverificationinc/runtimeverification-evm-semantics:ubuntu-focal-master

RUN apt-get -y update \ 
	&& apt-get install -y apt-utils \
	&& apt-get install -y software-properties-common \
	&& apt-get -y update \
    && apt-get install --reinstall ca-certificates \
    && update-ca-certificates
    
RUN add-apt-repository -y ppa:ethereum/ethereum \
	&& apt-get update \
	&& apt-get install -y solc
