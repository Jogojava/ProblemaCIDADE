package utils;

import java.util.Scanner;

import entities.Player;

public class InputHandler {
    public static Player createPlayer(Scanner sc) {
        System.out.print("\nNome do Player\n-> ");
        String name = sc.nextLine();

        System.out.print("\nReputação inicial (0-100)\n-> ");
        int reputation = sc.nextInt();
        sc.nextLine();

        return new Player(name, reputation);
    }
}