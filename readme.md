Rebar barcode reverb
====================

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
