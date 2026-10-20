package com.shopsphere.dao;

import com.shopsphere.model.Review;
import com.shopsphere.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    private static final String SQL_INSERT = 
        "INSERT INTO reviews (product_id, user_id, rating, title, comment, is_verified_purchase, status) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)";

    private static final String SQL_FIND_BY_PRODUCT_ID = 
        "SELECT review_id, product_id, user_id, rating, title, comment, is_verified_purchase, status, created_at, updated_at " +
        "FROM reviews WHERE product_id = ? AND status = 'approved' ORDER BY created_at DESC";

    public Review create(Review review) throws SQLException {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_INSERT, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, review.getProductId());
            ps.setLong(2, review.getUserId());
            ps.setInt(3, review.getRating() != null ? review.getRating() : 5);
            ps.setString(4, review.getTitle());
            ps.setString(5, review.getComment());
            ps.setBoolean(6, Boolean.TRUE.equals(review.getIsVerifiedPurchase()));
            ps.setString(7, review.getStatus() != null ? review.getStatus() : "approved");

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating review failed, no rows affected.");
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    review.setReviewId(rs.getLong(1));
                }
            }
            return review;
        }
    }

    public List<Review> findByProductId(Long productId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        if (productId == null || productId <= 0) {
            return reviews;
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(SQL_FIND_BY_PRODUCT_ID)) {

            ps.setLong(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp createdTs = rs.getTimestamp("created_at");
                    Timestamp updatedTs = rs.getTimestamp("updated_at");
                    reviews.add(new Review(
                        rs.getLong("review_id"),
                        rs.getLong("product_id"),
                        rs.getLong("user_id"),
                        rs.getInt("rating"),
                        rs.getString("title"),
                        rs.getString("comment"),
                        rs.getBoolean("is_verified_purchase"),
                        rs.getString("status"),
                        createdTs != null ? createdTs.toLocalDateTime() : null,
                        updatedTs != null ? updatedTs.toLocalDateTime() : null
                    ));
                }
            }
        }
        return reviews;
    }
}
