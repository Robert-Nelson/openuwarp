/*
 *  UWARP Atheros 7420 board support
 *
 *  Copyright (C) 2010 Gabor Juhos <juhosg@openwrt.org>
 *
 *  This program is free software; you can redistribute it and/or modify it
 *  under the terms of the GNU General Public License version 2 as published
 *  by the Free Software Foundation.
 */

#include <linux/gpio.h>
#include <linux/mtd/mtd.h>
#include <linux/mtd/partitions.h>

#include <asm/mach-ath79/ath79.h>
#include <asm/mach-ath79/ar71xx_regs.h>

#include "machtypes.h"
#include "dev-m25p80.h"
#include "dev-gpio-buttons.h"
#include "dev-leds-gpio.h"
#include "dev-usb.h"
#include "dev-eth.h"

#define UWARP_AR7420_GPIO_BTN_RESET	11
#define UWARP_AR7420_GPIO_BTN_QSS		12

#define UWARP_AR7420_KEYS_POLL_INTERVAL	20	/* msecs */
#define UWARP_AR7420_KEYS_DEBOUNCE_INTERVAL (3 * UWARP_AR7420_KEYS_POLL_INTERVAL)

#ifdef CONFIG_ATH79_MACH_UWARP_SPI_16M
static struct mtd_partition uwarp_ar7420_partitions[] = {
	{
		.name       = "u-boot",
		.offset     = 0,
		.size       = 0x030000,
		.mask_flags = MTD_WRITEABLE,
	}, {
		.name       = "kernel",
		.offset     = 0x030000,
		.size       = 0x200000,
	}, {
		.name       = "rootfs",
		.offset     = 0x230000,
		.size       = 0xDB0000,
	}, {
		.name       = "u-boot-env",
		.offset     = 0xFF0000,
		.size       = 0x010000,
//		.mask_flags = MTD_WRITEABLE,
	}, {
		.name       = "firmware",
		.offset     = 0x030000,
		.size       = 0xFB0000,
	}
};
static struct flash_platform_data uwarp_ar7420_flash_data = { 
	.parts      = uwarp_ar7420_partitions,
	.nr_parts   = ARRAY_SIZE(uwarp_ar7420_partitions),
}; 
#else
#ifdef CONFIG_ATH79_MACH_UWARP_SPI_8M
static struct mtd_partition uwarp_ar7420_partitions[] = {
	{
		.name       = "u-boot",
		.offset     = 0,
		.size       = 0x030000,
		.mask_flags = MTD_WRITEABLE,
	}, {
		.name       = "kernel",
		.offset     = 0x030000,
		.size       = 0x190000,
	}, {
		.name       = "rootfs",
		.offset     = 0x190000,
		.size       = 0x650000,
	}, {
		.name       = "u-boot-env",
		.offset     = 0x7F0000,
		.size       = 0x010000,
//		.mask_flags = MTD_WRITEABLE,
	}, {
		.name       = "firmware",
		.offset     = 0x030000,
		.size       = 0x7B0000,
	}
};
static struct flash_platform_data uwarp_ar7420_flash_data = { 
	.parts      = uwarp_ar7420_partitions,
	.nr_parts   = ARRAY_SIZE(uwarp_ar7420_partitions),
};
#else
#error ***** WARNING ***** Neither CONFIG_ATH79_MACH_UWARP_SPI_8M or CONFIG_ATH79_MACH_UWARP_SPI_16M is defined ******
#endif
#endif

static struct gpio_led uwarp_ar7420_leds_gpio[] __initdata = {
	{
		.name		= "uwarp-ar7420:red:led0",
		.gpio		= 0,
		.active_low	= 1,
	}, {
		.name		= "uwarp-ar7420:green:led0",
		.gpio		= 1,
		.active_low	= 1,
	}, 	{
		.name		= "uwarp-ar7420:red:led1",
		.gpio		= 13,
		.active_low	= 1,
	}, {
		.name		= "uwarp-ar7420:green:led1",
		.gpio		= 11,
		.active_low	= 1,
	}, {
		.name		= "uwarp-ar7420:wan:link",
		.gpio		= 15,
		.active_low	= 1,
	}, {
		.name		= "uwarp-ar7420:lan:link",
		.gpio		= 14,
		.active_low	= 1,
	}
};
/*
static struct gpio_keys_button uwarp_ar7420_gpio_keys[] __initdata = {
	{
		.desc		= "reset",
		.type		= EV_KEY,
		.code		= KEY_RESTART,
		.debounce_interval = UWARP_AR7420_KEYS_DEBOUNCE_INTERVAL,
		.gpio		= UWARP_AR7420_GPIO_BTN_RESET,
		.active_low	= 1,
	}, {
		.desc		= "qss",
		.type		= EV_KEY,
		.code		= KEY_WPS_BUTTON,
		.debounce_interval = UWARP_AR7420_KEYS_DEBOUNCE_INTERVAL,
		.gpio		= UWARP_AR7420_GPIO_BTN_QSS,
		.active_low	= 1,
	}
};
*/

static void __init uwarp_ar7x20_setup(void)
{
	u8 *mac = (u8 *) KSEG1ADDR(0x1ffe0000);
	//u8 *ee = (u8 *) KSEG1ADDR(0x1fff1000);

	/* enable power for the USB port */
//	gpio_request(UWARP_AR7420_GPIO_USB_POWER, "USB power");
//	gpio_direction_output(UWARP_AR7420_GPIO_USB_POWER, 1);

	ath79_register_m25p80(&uwarp_ar7420_flash_data);

	ath79_register_leds_gpio(-1, ARRAY_SIZE(uwarp_ar7420_leds_gpio),
					uwarp_ar7420_leds_gpio);

/*
	ar71xx_register_gpio_keys_polled(-1, UWARP_AR7420_KEYS_POLL_INTERVAL,
					 ARRAY_SIZE(uwarp_ar7420_gpio_keys),
					 uwarp_ar7420_gpio_keys);
*/

	ath79_eth1_data.is_ar724x = 1;
	uwarp_ath79_init_mac(ath79_eth0_data.mac_addr, mac, 0);
	printk("MAC: eth0 %02x:%02x:%02x:%02x:%02x:%02x\n", ath79_eth0_data.mac_addr[0],ath79_eth0_data.mac_addr[1],ath79_eth0_data.mac_addr[2],
		ath79_eth0_data.mac_addr[3],ath79_eth0_data.mac_addr[4],ath79_eth0_data.mac_addr[5]);

	uwarp_ath79_init_mac(ath79_eth1_data.mac_addr, mac, 1);
	printk("MAC: eth1 %02x:%02x:%02x:%02x:%02x:%02x\n", ath79_eth1_data.mac_addr[0],ath79_eth1_data.mac_addr[1],ath79_eth1_data.mac_addr[2],
		ath79_eth1_data.mac_addr[3],ath79_eth1_data.mac_addr[4],ath79_eth1_data.mac_addr[5]);

    //ath79_init_mac(ath79_eth0_data.mac_addr, mac, 1); 
	//ath79_init_mac(ath79_eth1_data.mac_addr, mac, -1);

	/* WAN port */
	ath79_eth0_data.phy_if_mode = PHY_INTERFACE_MODE_RMII;
	ath79_eth0_data.speed = SPEED_100;
	ath79_eth0_data.duplex = DUPLEX_FULL;
	ath79_eth0_data.phy_mask = BIT(4); //PHY ID=4

	/* LAN ports */
	ath79_eth1_data.phy_if_mode = PHY_INTERFACE_MODE_RMII;
	ath79_eth1_data.speed = SPEED_100;
	ath79_eth1_data.duplex = DUPLEX_FULL;


	ath79_register_mdio(0,0x0);
	ath79_register_eth(0);
	ath79_register_eth(1);

	ath79_register_usb();

}

static void __init uwarp_ar7420_setup(void)
{
	uwarp_ar7x20_setup();
}

MIPS_MACHINE(ATH79_MACH_UWARP_AR7420, "UWARP-AR7420", "PIKA UWARP-AR7420",
						 uwarp_ar7420_setup);
