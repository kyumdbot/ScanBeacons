# iBeacon Scanner for macOS


## Screenshot

![screenshot](imgs/1.png)


## Advertisement Data (*kCBAdvDataManufacturerData*) Format

![Manufacturer Data Format](imgs/kCBAdvDataManufacturerData_format.png)

- Company ID: Apple's Bluetooth SIG registered company code.
- Type: Apple's iBeacon type of Custom Manufacturer Data.
- Data Length: ProximityUUID + Major + Minor + MeasuredPower.
- Proximity UUID: 16 Bytes String.
- Major: Unsigned Integer value, 16-bit Big Endian.
- Minor: Unsigned Integer value, 16-bit Big Endian.
- Measured Power: 8-bit Signed value.


<br>



## License

(MIT License)

Copyright (c) 2021 Wei-Cheng Ling.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.