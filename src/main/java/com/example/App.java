package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello from " + System.getProperty("env", "default") + " environment!");
    }
}