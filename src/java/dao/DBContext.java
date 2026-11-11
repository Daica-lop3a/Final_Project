package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * The only place that opens a database connection.
 *
 * The project uses sqljdbc4.jar and nothing else. That driver is old enough to
 * predate automatic driver loading, so Class.forName stays here on purpose, and
 * the URL carries no encrypt property because sqljdbc4 does not understand the
 * newer ones.
 */
public class DBContext {

    private static final String URL =
        "jdbc:sqlserver://localhost:1433;databaseName=SmartWasteDB";
    private static final String USER = "sa";
    private static final String PASS = "12345";

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(
                "sqljdbc4.jar is missing from the project libraries", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /** Closes whatever is not null, in the right order, swallowing nothing useful. */
    public static void close(ResultSet rs, Statement st, Connection cn) {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) { }
        try { if (st != null) st.close(); } catch (SQLException ignored) { }
        try { if (cn != null) cn.close(); } catch (SQLException ignored) { }
    }

    public static void close(PreparedStatement ps, Connection cn) {
        close(null, ps, cn);
    }
}
