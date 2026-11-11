package model;

import java.sql.Timestamp;

public class BinReading {

    private int readingID;
    private String binID;
    private int fillPercent;
    private Timestamp measuredAt;

    public BinReading() {
    }

    public int getReadingID() {
        return readingID;
    }

    public void setReadingID(int readingID) {
        this.readingID = readingID;
    }

    public String getBinID() {
        return binID;
    }

    public void setBinID(String binID) {
        this.binID = binID;
    }

    public int getFillPercent() {
        return fillPercent;
    }

    public void setFillPercent(int fillPercent) {
        this.fillPercent = fillPercent;
    }

    public Timestamp getMeasuredAt() {
        return measuredAt;
    }

    public void setMeasuredAt(Timestamp measuredAt) {
        this.measuredAt = measuredAt;
    }
}