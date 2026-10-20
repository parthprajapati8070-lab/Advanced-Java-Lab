package com.shopsphere.util;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DatabaseSeeder {

    private static volatile boolean initialized = false;

    public static synchronized void seedIfNeeded() {
        if (initialized) {
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            ensureImageUrlColumn(conn);
            ensureProductsSeeded(conn);
            initialized = true;
        } catch (SQLException e) {
            System.err.println("[DatabaseSeeder] Warning during schema initialization: " + e.getMessage());
        }
    }

    private static void ensureImageUrlColumn(Connection conn) throws SQLException {
        DatabaseMetaData meta = conn.getMetaData();
        boolean hasColumn = false;
        try (ResultSet rs = meta.getColumns(null, null, "products", "image_url")) {
            if (rs.next()) {
                hasColumn = true;
            }
        }
        if (!hasColumn) {
            try (Statement stmt = conn.createStatement()) {
                stmt.executeUpdate("ALTER TABLE products ADD COLUMN image_url VARCHAR(500) NULL AFTER description");
                System.out.println("[DatabaseSeeder] Added 'image_url' column to 'products' table.");
            }
        }
    }

    private static void ensureProductsSeeded(Connection conn) throws SQLException {
        int count = 0;
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM products WHERE image_url IS NOT NULL AND image_url != ''")) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        }

        // If table has fewer than 36 products with image_url, seed/update all 36 products
        if (count < 36) {
            String sql = "INSERT INTO products (product_id, category_id, sku, name, slug, description, image_url, price, sale_price, stock_quantity, status) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE " +
                         "category_id=VALUES(category_id), name=VALUES(name), slug=VALUES(slug), description=VALUES(description), " +
                         "image_url=VALUES(image_url), price=VALUES(price), sale_price=VALUES(sale_price), " +
                         "stock_quantity=VALUES(stock_quantity), status=VALUES(status)";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                for (Object[] p : PRODUCTS) {
                    ps.setLong(1, (Long) p[0]);
                    ps.setInt(2, (Integer) p[1]);
                    ps.setString(3, (String) p[2]);
                    ps.setString(4, (String) p[3]);
                    ps.setString(5, (String) p[4]);
                    ps.setString(6, (String) p[5]);
                    ps.setString(7, (String) p[6]);
                    ps.setBigDecimal(8, (BigDecimal) p[7]);
                    if (p[8] != null) {
                        ps.setBigDecimal(9, (BigDecimal) p[8]);
                    } else {
                        ps.setNull(9, java.sql.Types.DECIMAL);
                    }
                    ps.setInt(10, (Integer) p[9]);
                    ps.setString(11, (String) p[10]);
                    ps.addBatch();
                }
                ps.executeBatch();
                System.out.println("[DatabaseSeeder] Successfully seeded " + PRODUCTS.length + " products into MySQL database.");
            }
        }
    }

    private static final Object[][] PRODUCTS = {
        // === CATEGORY 1: ELECTRONICS ===
        {
            1L, 1, "SKU-ELEC-LAPTOP-01", "UltraBook Pro 15.6\" Laptop", "ultrabook-pro-15",
            "High-performance laptop featuring a 15.6\" Full HD display, 16GB RAM, 512GB NVMe SSD, and Intel Core i7 processor.",
            "assets/images/products/laptop-01.jpg",
            new BigDecimal("69999.00"), new BigDecimal("64999.00"), 25, "active"
        },
        {
            2L, 1, "SKU-ELEC-PHONE-02", "NexGen 5G Flagship Smartphone", "nexgen-5g-smartphone",
            "Next-gen flagship smartphone with 120Hz AMOLED screen, 50MP AI triple camera, and 5000mAh battery.",
            "assets/images/products/smartphone-01.jpg",
            new BigDecimal("44999.00"), new BigDecimal("39999.00"), 50, "active"
        },
        {
            3L, 1, "SKU-ELEC-HEADPHONE-03", "AcousticPro ANC Wireless Headphones", "acousticpro-anc-headphones",
            "Over-ear wireless headphones with active noise cancellation, high-res audio, and 40-hour battery life.",
            "assets/images/products/headphones-01.jpg",
            new BigDecimal("9999.00"), new BigDecimal("7999.00"), 80, "active"
        },
        {
            4L, 1, "SKU-ELEC-KEYBOARD-04", "Mechanical RGB Gaming Keyboard", "mechanical-rgb-keyboard",
            "Customizable RGB backlit mechanical keyboard with tactile blue switches and aluminum top frame.",
            "assets/images/products/keyboard-01.jpg",
            new BigDecimal("3499.00"), new BigDecimal("2899.00"), 40, "active"
        },
        {
            5L, 1, "SKU-ELEC-MOUSE-05", "Ergonomic Precision Wireless Mouse", "ergonomic-wireless-mouse",
            "Rechargeable multi-device Bluetooth mouse with adjustable DPI sensor and silent tactile clicks.",
            "assets/images/products/mouse-01.jpg",
            new BigDecimal("1999.00"), new BigDecimal("1499.00"), 65, "active"
        },
        {
            6L, 1, "SKU-ELEC-WATCH-06", "Titan AMOLED Fitness Smartwatch", "titan-amoled-smartwatch",
            "IP68 waterproof smartwatch with continuous heart-rate tracking, SpO2 sensor, and 14-day battery life.",
            "assets/images/products/smartwatch-01.jpg",
            new BigDecimal("6499.00"), new BigDecimal("4999.00"), 60, "active"
        },
        {
            7L, 1, "SKU-ELEC-MONITOR-07", "27\" 4K UHD IPS Designer Monitor", "27-inch-4k-uhd-monitor",
            "Ultra-slim bezel 27-inch 4K IPS display with 99% sRGB color accuracy, HDR10, and USB-C power delivery.",
            "assets/images/products/monitor-01.jpg",
            new BigDecimal("24999.00"), new BigDecimal("21999.00"), 30, "active"
        },
        {
            8L, 1, "SKU-ELEC-SPEAKER-08", "BassBoom 360° Portable Bluetooth Speaker", "bassboom-portable-speaker",
            "Rugged IPX7 waterproof wireless speaker delivering deep 360-degree sound with 24 hours of playback.",
            "assets/images/products/speaker-01.jpg",
            new BigDecimal("4299.00"), new BigDecimal("3499.00"), 45, "active"
        },
        {
            9L, 1, "SKU-ELEC-TABLET-09", "TabX Pro 11\" 2K Octa-Core Tablet", "tabx-pro-11-tablet",
            "Sleek metallic tablet with 11-inch 2K IPS screen, quad stereo speakers, and stylus pen support.",
            "assets/images/products/tablet-01.jpg",
            new BigDecimal("27999.00"), new BigDecimal("23999.00"), 35, "active"
        },
        {
            10L, 1, "SKU-ELEC-CAMERA-10", "4K Ultra HD Mirrorless Camera", "4k-mirrorless-camera",
            "Compact 24.2MP mirrorless digital camera with fast hybrid autofocus, 4K video recording, and interchangeable lens.",
            "assets/images/products/camera-01.jpg",
            new BigDecimal("54999.00"), new BigDecimal("48999.00"), 15, "active"
        },
        {
            11L, 1, "SKU-ELEC-PBANK-11", "20000mAh 65W Fast Charge Power Bank", "20000mah-fast-charge-power-bank",
            "High-capacity portable battery with 65W Power Delivery output capable of charging laptops and phones rapidly.",
            "assets/images/products/powerbank-01.jpg",
            new BigDecimal("2999.00"), new BigDecimal("2299.00"), 70, "active"
        },

        // === CATEGORY 2: APPAREL & FASHION ===
        {
            12L, 2, "SKU-FASH-TSHIRT-12", "Classic Crewneck Organic Cotton T-Shirt", "classic-crewneck-tshirt",
            "100% bio-washed combed organic cotton tee offering breathable comfort and a tailored modern fit.",
            "assets/images/products/tshirt-01.jpg",
            new BigDecimal("899.00"), new BigDecimal("699.00"), 120, "active"
        },
        {
            13L, 2, "SKU-FASH-HOODIE-13", "Heavyweight Fleece Pullover Hoodie", "heavyweight-fleece-hoodie",
            "Cozy 380 GSM brushed fleece hoodie with double-lined drawstring hood and kangaroo pouch pocket.",
            "assets/images/products/hoodie-01.jpg",
            new BigDecimal("2499.00"), new BigDecimal("1899.00"), 65, "active"
        },
        {
            14L, 2, "SKU-FASH-JEANS-14", "Slim Fit Stretch Indigo Denim Jeans", "slim-fit-indigo-jeans",
            "Premium authentic dark wash denim crafted with 2% elastane for flexible all-day mobility.",
            "assets/images/products/jeans-01.jpg",
            new BigDecimal("2799.00"), new BigDecimal("2199.00"), 55, "active"
        },
        {
            15L, 2, "SKU-FASH-SNEAKER-15", "AeroStride Urban Cushion Sneakers", "aerostride-urban-sneakers",
            "Breathable knit athletic sneakers with responsive cloud-foam sole cushioning and slip-resistant rubber tread.",
            "assets/images/products/sneakers-01.jpg",
            new BigDecimal("3999.00"), new BigDecimal("3299.00"), 40, "active"
        },
        {
            16L, 2, "SKU-FASH-JACKET-16", "All-Weather Windbreaker Bomber Jacket", "all-weather-bomber-jacket",
            "Lightweight water-repellent jacket featuring ribbed cuffs, zipper storm flap, and secure interior pockets.",
            "assets/images/products/jacket-01.jpg",
            new BigDecimal("4499.00"), new BigDecimal("3599.00"), 35, "active"
        },
        {
            17L, 2, "SKU-FASH-WATCH-17", "Heritage Chronograph Leather Watch", "heritage-chronograph-watch",
            "Sophisticated analog timepiece with genuine top-grain leather strap, sapphire crystal glass, and date display.",
            "assets/images/products/watch-01.jpg",
            new BigDecimal("6999.00"), new BigDecimal("5499.00"), 30, "active"
        },
        {
            18L, 2, "SKU-FASH-BACKPACK-18", "Urban Commuter Waterproof Backpack", "urban-commuter-backpack",
            "28L weatherproof travel backpack featuring a TSA-approved 16\" laptop sleeve and anti-theft hidden pocket.",
            "assets/images/products/backpack-01.jpg",
            new BigDecimal("2899.00"), new BigDecimal("2299.00"), 90, "active"
        },
        {
            19L, 2, "SKU-FASH-TSHIRT-19", "Oversized Graphic Streetwear Tee", "oversized-graphic-tee",
            "Trendy drop-shoulder streetwear graphic t-shirt made with heavy 240 GSM breathable cotton fabric.",
            "assets/images/products/tshirt-02.jpg",
            new BigDecimal("1199.00"), new BigDecimal("899.00"), 85, "active"
        },
        {
            20L, 2, "SKU-FASH-JACKET-20", "Vintage Washed Denim Trucker Jacket", "vintage-denim-jacket",
            "Classic rugged trucker jacket with signature metal button closure, button-flap chest pockets, and waist adjusters.",
            "assets/images/products/jacket-02.jpg",
            new BigDecimal("4999.00"), new BigDecimal("3999.00"), 25, "active"
        },

        // === CATEGORY 3: HOME & LIVING ===
        {
            21L, 3, "SKU-HOME-LAMP-21", "Minimalist LED Architecture Desk Lamp", "minimalist-led-desk-lamp",
            "Dimmable architect clamp lamp with 5 color temperatures, eye-care flicker-free LED panel, and touch controls.",
            "assets/images/products/desk-lamp-01.jpg",
            new BigDecimal("2499.00"), new BigDecimal("1999.00"), 50, "active"
        },
        {
            22L, 3, "SKU-HOME-CHAIR-22", "Ergonomic High-Back Mesh Office Chair", "ergonomic-mesh-office-chair",
            "Commercial-grade ergonomic desk chair with adjustable lumbar support, 3D armrests, and breathable mesh back.",
            "assets/images/products/office-chair-01.jpg",
            new BigDecimal("12999.00"), new BigDecimal("10499.00"), 20, "active"
        },
        {
            23L, 3, "SKU-HOME-BED-23", "400 TC Egyptian Cotton Bedsheet Set", "egyptian-cotton-bedsheet-set",
            "Luxury king-size bedsheet set woven from long-staple satin cotton with matching pillowcases.",
            "assets/images/products/bedsheet-01.jpg",
            new BigDecimal("3299.00"), new BigDecimal("2599.00"), 45, "active"
        },
        {
            24L, 3, "SKU-HOME-ORG-24", "Multi-Tier Modular Storage Organizer", "modular-storage-organizer",
            "Collapsible closet and shelf organizer bins with reinforced handles and transparent display windows.",
            "assets/images/products/storage-01.jpg",
            new BigDecimal("1599.00"), new BigDecimal("1299.00"), 75, "active"
        },
        {
            25L, 3, "SKU-HOME-DECOR-25", "Artisan Ceramic Nordic Vase & Decor", "artisan-ceramic-vase",
            "Handcrafted matte ceramic decorative vase ideal for dried florals, centerpieces, or contemporary living rooms.",
            "assets/images/products/vase-01.jpg",
            new BigDecimal("1299.00"), new BigDecimal("999.00"), 60, "active"
        },
        {
            26L, 3, "SKU-HOME-KITCHEN-26", "Pre-Seasoned Cast Iron Chef Skillet", "cast-iron-chef-skillet",
            "Heavy-duty 10-inch pre-seasoned cast iron frying pan for stovetop, oven, and grill culinary cooking.",
            "assets/images/products/skillet-01.jpg",
            new BigDecimal("2199.00"), new BigDecimal("1699.00"), 40, "active"
        },
        {
            27L, 3, "SKU-HOME-DIFF-27", "Aromatherapy Ultrasonic Essential Oil Diffuser", "ultrasonic-oil-diffuser",
            "Quiet 500ml wood-grain ultrasonic cool mist humidifier with 7 soothing ambient LED light modes.",
            "assets/images/products/diffuser-01.jpg",
            new BigDecimal("1799.00"), new BigDecimal("1399.00"), 65, "active"
        },
        {
            28L, 3, "SKU-HOME-KNIFE-28", "Stainless Steel Precision Knife Block Set", "knife-block-set-6pc",
            "High-carbon stainless steel 6-piece kitchen knife collection with ergonomic handles and acacia wooden block.",
            "assets/images/products/knives-01.jpg",
            new BigDecimal("3999.00"), new BigDecimal("3199.00"), 30, "active"
        },

        // === CATEGORY 4: ACCESSORIES ===
        {
            29L, 4, "SKU-ACC-WALLET-29", "Slim RFID-Blocking Genuine Leather Wallet", "rfid-leather-wallet",
            "Handcrafted bifold leather wallet featuring an integrated RFID signal protection layer and quick-access card slots.",
            "assets/images/products/wallet-01.jpg",
            new BigDecimal("1499.00"), new BigDecimal("1199.00"), 95, "active"
        },
        {
            30L, 4, "SKU-ACC-SUNGLASS-30", "Polarized UV400 Aviator Sunglasses", "polarized-aviator-sunglasses",
            "Classic metal frame aviators equipped with shatterproof polarized lenses that filter 100% of harmful UVA/UVB rays.",
            "assets/images/products/sunglasses-01.jpg",
            new BigDecimal("2199.00"), new BigDecimal("1699.00"), 70, "active"
        },
        {
            31L, 4, "SKU-ACC-CASE-31", "Shockproof Matte Armor Phone Case", "shockproof-matte-phone-case",
            "Military drop-tested hybrid phone case with raised camera bevels and fingerprint-resistant translucent back.",
            "assets/images/products/phonecase-01.jpg",
            new BigDecimal("799.00"), new BigDecimal("499.00"), 150, "active"
        },
        {
            32L, 4, "SKU-ACC-CABLE-32", "Braided 100W USB-C to USB-C Fast Cable (2m)", "100w-braided-usbc-cable",
            "Nylon double-braided fast charging cable supporting 100W PD charging and 480Mbps ultra-fast data transfer.",
            "assets/images/products/cable-01.jpg",
            new BigDecimal("699.00"), new BigDecimal("449.00"), 200, "active"
        },
        {
            33L, 4, "SKU-ACC-BAG-33", "Executive Padded Leatherette Laptop Sleeve", "padded-laptop-sleeve",
            "Water-resistant premium leatherette envelope sleeve with soft velvet inner lining for 14-15\" notebooks.",
            "assets/images/products/laptop-bag-01.jpg",
            new BigDecimal("1899.00"), new BigDecimal("1399.00"), 60, "active"
        },
        {
            34L, 4, "SKU-ACC-TRAVEL-34", "Compact Compression Packing Cubes (Set of 6)", "compression-packing-cubes",
            "Double-zipper expandable compression travel organizer cubes crafted from durable ripstop nylon.",
            "assets/images/products/travel-01.jpg",
            new BigDecimal("1699.00"), new BigDecimal("1299.00"), 80, "active"
        },
        {
            35L, 4, "SKU-ACC-PILLOW-35", "Memory Foam Travel Neck Support Pillow", "memory-foam-travel-pillow",
            "360-degree ergonomic contour travel pillow with high-density memory foam core and washable plush cover.",
            "assets/images/products/pillow-01.jpg",
            new BigDecimal("1199.00"), new BigDecimal("899.00"), 75, "active"
        },
        {
            36L, 4, "SKU-ACC-ORGANIZER-36", "Water-Resistant Electronic Tech Organizer Case", "electronic-tech-organizer",
            "Double-layered cable and gadgets carry case with elastic loops, mesh pockets, and water-repellent shell.",
            "assets/images/products/tech-pouch-01.jpg",
            new BigDecimal("1399.00"), new BigDecimal("999.00"), 85, "active"
        }
    };
}
