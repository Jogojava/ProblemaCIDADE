package entities;

public class Player {
    String name;
    int reputation;

    public Player (String name, int reputation) {
        this.name = name;
        this.reputation = reputation;
    }

    public void printPlayerStats() {
        System.out.println("\n* " + name + "\n* " + reputation + " de reputação");
    }
}