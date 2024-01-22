# Welcome to Prodrive Technologies (IC) Yocto Meta Layer
Kirkstone 4.0
- linux 5.15.32 (linux-ptic)

To use this layer to build an image, include it in your project specific manifest.
An example manifest wrapping meta-ptic can be found here:
https://bitbucket.prodrive.nl/projects/PTIC203904/repos/ptic-manifest

## Documentation
- Platforms:
	- i.MX8M:
		- [SPD: iMX8M Firmware](https://orionfs.app.local/pn/6001231875)
		- [DSD: iMX8M Firmware](https://orionfs.app.local/pn/6001231877)
		- [UMD: iMX8M Firmware](https://orionfs.app.local/pn/6001231879)
		- [TRD: iMX8M Firmware](https://orionfs.app.local/pn/6001232308)
	- i.MX6ULx:
		- [SPD: iMX6ULx Firmware](https://orionfs.app.local/pn/6001231874)
		- [DSD: iMX6ULx Firmware](https://orionfs.app.local/pn/6001231876)
		- [UMD: iMX6ULx Firmware](https://orionfs.app.local/pn/6001231878)
		- [TRD: iMX6ULx Firmware](https://orionfs.app.local/pn/6001232307)
- [RND: PTIC Firmware 1.x.x](https://orionfs.app.local/pn/6001231881)
- [Dashboard](https://ptic.prodrive.nl/main/)

## Machines
The meta-ptic layer contains the following machine specifications:
- i.MX8M Mini: imx8mm-ptic-base
- i.MX8M Nano: imx8mn-ptic-base
- i.MX8M Plus: imx8mp-ptic-base
- I.MX6ULL: imx6ull-ptic-base

### Using PTIC Yocto Environment
Building PTIC BSP software can be done by integrating the meta-ptic layer into the Yocto environment.
An user guide for installing and using PTIC can be found in designated UMD.
