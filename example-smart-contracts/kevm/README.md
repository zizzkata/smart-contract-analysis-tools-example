# kevm
To get in contact with the developers of the k-framework and kevm, go to the channel on [Riot](https://riot.im/app/#/room/#k:matrix.org).

See the [VeriToken-spec.md](./kevm/VeriToken-spec.md) in `./kevm` for instructions. 

An example output of a **successful** spec can be found in [VeriToken-kevm.result](./kevm/VeriToken-kevm.result). 

An example output of a **failing** spec can be found in [VeriToken-kevm.failing-result](./kevm/VeriToken-kevm.failing-result). In the failing spec the we said that `decimals()` should return 18 (`<output> .ByteArray => #buf(32, 18) </output>`) while actually is should return 6 as described in [VeriToken-spec.md](./kevm/VeriToken-spec.md).