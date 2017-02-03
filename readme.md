Rebar barcode reverb
====================

Since the dawn of the UNIX epoch, mankind has been using barcodes to solve the
problems of our modern world. Meanwhile, apart from a few examples like overtly
symbolic tattoos, barcodes have been severely underutilized in the realm of
culture and entertainment. Let's take a step in this direction!

This is a proof-of-concept for creating an audio FX app where parameter input is
provided through scanning bar- and QR codes.

This code was written as part of a "personal project" generously funded by my
employer, Allihoopa AB.

Features
--------
* AVCaptureVideoPreviewLayer provides camera view and captures metadata from
camera using AVCaptureMetadataOutputObjectsDelegate
* Metadata is mapped to audio FX parameter space
* AVAudioEngine graph consisting of a delay-reverb chain processes incoming audio

Mode of operation
-----------------
Launch app, using some suitable audio setup to avoid mic feedback (headphones
are fine). Aim camera at some barcode:
* Green outline = found a numeric barcode, it's value is used to alter the FX parameters
* Red outline = found a barcode whose value could not be used for parameters
* Brown outline = found a metadata object in the image that is something other than a barcode (point at someone's face to try it out!)

License
-------
Rebar barcode reverb copyright © 2017 Arvid Rudling/Allihoopa AB.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
