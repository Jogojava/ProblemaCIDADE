import entities.Player;
import utils.InputHandler;

import java.util.Scanner;

public class Main {
    public static void main (String[] args) {
        Scanner sc = new Scanner(System.in);

        Player player = InputHandler.createPlayer(sc);
        player.printPlayerStats();

        sc.close();
    }
}