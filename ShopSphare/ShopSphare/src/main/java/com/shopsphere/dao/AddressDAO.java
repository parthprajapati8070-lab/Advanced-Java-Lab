package com.shopsphere.dao;

import com.shopsphere.model.Address;
import com.shopsphere.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class AddressDAO {

    private static final String SQL_INSERT = 
        "INSERT INTO addresses (user_id, address_type, is_default, recipient_name, phone_number, " +
        "street_address_line1, street_address_line2, city, state, postal_code, country) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_FIND_BY_ID = 
        "SELECT address_id, user_id, address_type, is_default, recipient_name, phone_number, " +
        "street_address_line1, street_address_line2, city, state, postal_code, country, created_at, updated_at " +
        "FROM addresses WHERE address_id = ?";

    private static final String SQL_FIND_BY_USER_ID = 
        "SELECT address_id, user_id, address_type, is_default, recipient_name, phone_number, " +
        "street_address_line1, street_address_line2, city, state, postal_code, country, created_at, updated_at " +
        "FROM addresses WHERE user_id = ? ORDER BY is_default DESC, created_at DESC";

    private static final String SQL_FIND_DEFAULT_BY_USER_ID = 
        "SELECT address_id, user_id, address_type, is_default, recipient_name, phone_number, " +
        "street_address_line1, street_address_line2, city, state, postal_code, country, created_at, updated_at " +
        "FROM addresses WHERE user_id = ? AND is_default = TRUE LIMIT 1";

    public Address create(Address address) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, address.getUserId());
            ps.setString(2, address.getAddressType() != null ? address.getAddressType() : "shipping");
            ps.setBoolean(3, Boolean.TRUE.equals(address.getIsDefault()));
            ps.setString(4, address.getRecipientName());
            ps.setString(5, address.getPhoneNumber());
            ps.setString(6, address.getStreetAddressLine1());
            ps.setString(7, address.getStreetAddressLine2());
            ps.setString(8, address.getCity());
            ps.setString(9, address.getState());
            ps.setString(10, address.getPostalCode());
            ps.setString(11, address.getCountry() != null ? address.getCountry() : "USA");

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating address failed, no rows affected.");
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    address.setAddressId(rs.getLong(1));
                } else {
                    throw new SQLException("Creating address failed, no ID obtained.");
                }
            }
            return address;
        }
    }

    public Optional<Address> findById(Long addressId) throws SQLException {
        if (addressId == null || addressId <= 0) {
            return Optional.empty();
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_ID)) {

            ps.setLong(1, addressId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToAddress(rs));
                }
            }
        }
        return Optional.empty();
    }

    public List<Address> findByUserId(Long userId) throws SQLException {
        List<Address> addresses = new ArrayList<>();
        if (userId == null || userId <= 0) {
            return addresses;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_USER_ID)) {

            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    addresses.add(mapResultSetToAddress(rs));
                }
            }
        }
        return addresses;
    }

    public Optional<Address> findDefaultByUserId(Long userId) throws SQLException {
        if (userId == null || userId <= 0) {
            return Optional.empty();
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_DEFAULT_BY_USER_ID)) {

            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapResultSetToAddress(rs));
                }
            }
        }
        return Optional.empty();
    }

    private Address mapResultSetToAddress(ResultSet rs) throws SQLException {
        Timestamp createdTs = rs.getTimestamp("created_at");
        Timestamp updatedTs = rs.getTimestamp("updated_at");

        return new Address(
            rs.getLong("address_id"),
            rs.getLong("user_id"),
            rs.getString("address_type"),
            rs.getBoolean("is_default"),
            rs.getString("recipient_name"),
            rs.getString("phone_number"),
            rs.getString("street_address_line1"),
            rs.getString("street_address_line2"),
            rs.getString("city"),
            rs.getString("state"),
            rs.getString("postal_code"),
            rs.getString("country"),
            createdTs != null ? createdTs.toLocalDateTime() : null,
            updatedTs != null ? updatedTs.toLocalDateTime() : null
        );
    }
}
