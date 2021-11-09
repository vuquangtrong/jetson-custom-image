# jetson-custom-image
 Create a custom image for Jetson boards


## How to

1. Firstly, edit the variables in `step0_env.sh`

    In here, you can change release version of Ubuntu and Jetson BSP.  
    You have to set directories for RootFs and Build image  
    You can choose a Desktop Environment.

2. Run `step1_make_rootfs.sh`

    This step creates a base RootFs in `ROOT_DIR`.
    The base version of Ubuntu will be downloaded and unpacked.

3. Run `step2_customize_rootfs.sh`

    This step installs necessary packages for Jetson libs, and X11 GUI server.  
    It will download a Desktop environment if you do select one.  
    It does some configurations to the RootFs.

4. Run `step3_apply_bsp.sh`

    This step downloads Jetson BSP including bootloader, Linux kernel, Linux headers, drivers and libraries.  
    It also create an user for you too.

5. Run `step4_flash.sh`

    Put your board into Recovery Mode, and this step will flash your board with new system image.

6. Run `step5_create_image.sh` 
    
    If you want to create and image file for flashing to a micro-SD Card, run this step before doing the next step.

7. Run `step6_flash_SD.sh`

    This step will write the system image to your micro-SD card.  
    It also expands the application partition to use all of space of your card.

## License 

MIT
