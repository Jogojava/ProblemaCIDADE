package entities;

public class Player {
    private String name;
    private int reputation;

    public Player(String name, int reputation) {
        this.name = name;
        this.reputation = reputation;
    }

    public String getName() {
        return name;
    }

    public int getReputation() {
        return reputation;
    }
}