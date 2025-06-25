package com.buddy.pium.util;

public class AddressParser {
    public static String[] parse(String address) {
        if (address == null || address.trim().isEmpty()) return new String[]{"", "", ""};
        String[] tokens = address.split(" ");
        String city = tokens.length > 0 ? tokens[0] : "";
        String district = tokens.length > 1 ? tokens[1] : "";
        String dong = tokens.length > 2 ? tokens[2] : "";
        return new String[]{city, district, dong};
    }
}
