# QRCodeApp
The repo for my Facharbeit
A Facharbeit (I think term paper in English) is like a preparation for science papers in uni.
It's a task from my high school (Gymnasium in Germany).
The program is supposed to generate QR-Code with Byte Mode, M error Correction and Masking pattern 1; up to version 10.

The code should be finished now. The only missing thing are more comments. A small problem could be that the programm crashes, when an ä, ö or ü appears in the message. However, this is not fixed easily, since these special vowels are special cases in UTF-8, which is the character set I am using. <br>
Additionally, the program can only be used, if the device is on light mode, since I am only drawing black pixels, which cant't be seen on a black bakground <i> duh </i>. This could be fixed, by also drawing the white modules, as well as the 4-module wide margin. However, I just don't want to :P


## Usage
The program runs in Xcode with SwiftUI and Swift 5 and is written for iOS. I think it should be pretty easy to downgrade the needed iOS version, but I do not have enough experience with such things.
