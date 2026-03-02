import QtQuick

QtObject {
    id: theme

    property string current: "catppuccin"

    property color barText: current === "light" ? "#1f2937" : "#e6e6ff"
    property color mutedText: current === "light" ? "#4b5563" : "#a8acd9"
    property color accent: current === "catppuccin" ? "#cba6f7" : (current === "dark" ? "#7dcfff" : "#ef5f84")
    property color accent2: current === "catppuccin" ? "#89b4fa" : (current === "dark" ? "#569cd6" : "#f2a65a")
    property color accentSoft: current === "catppuccin" ? "#33cba6f7" : (current === "dark" ? "#337dcfff" : "#33ef5f84")
    property color accent2Soft: current === "catppuccin" ? "#3389b4fa" : (current === "dark" ? "#33569cd6" : "#33f2a65a")
    property color surface: current === "light" ? "#f5f7fae0" : (current === "dark" ? "#0b1220dd" : "#0a081add")
    property color surfaceAlt: current === "light" ? "#fffffff0" : (current === "dark" ? "#131d33dd" : "#141022dd")
    property color border: current === "light" ? "#ef5f8499" : (current === "dark" ? "#7dcfff99" : "#cba6f799")
}
