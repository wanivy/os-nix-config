import argparse
from pathlib import Path
from xml.etree import ElementTree as ET


def write_xml(output, name, root):
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output / name, encoding="utf-8")


def add_jdk(table, major, home):
    release = dict(
        line.split("=", 1)
        for line in (home / "release").read_text().splitlines()
        if "=" in line
    )
    version = release["JAVA_VERSION"].strip('"')
    sdk_home = f"$USER_HOME$/.jdks/java-{major}"
    jdk = ET.SubElement(table, "jdk", version="2")
    ET.SubElement(jdk, "name", value=f"OpenJDK {major}")
    ET.SubElement(jdk, "type", value="JavaSDK")
    ET.SubElement(jdk, "version", value=f'java version "{version}"')
    ET.SubElement(jdk, "homePath", value=sdk_home)
    roots = ET.SubElement(jdk, "roots")
    for kind in ["annotationsPath", "classPath", "javadocPath", "sourcePath"]:
        composite = ET.SubElement(ET.SubElement(roots, kind), "root", type="composite")
        if kind == "classPath":
            modules = sorted((home / "jmods").glob("*.jmod"))
            if not modules:
                raise ValueError(f"No Java modules found in {home}")
            for module in modules:
                ET.SubElement(
                    composite,
                    "root",
                    url=f"jrt://{sdk_home}!/{module.stem}",
                    type="simple",
                )
        elif kind == "sourcePath" and (home / "lib/src.zip").exists():
            ET.SubElement(
                composite,
                "root",
                url=f"jar://{sdk_home}/lib/src.zip!/",
                type="simple",
            )
    ET.SubElement(jdk, "additional")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--java21", required=True, type=Path)
    parser.add_argument("--java25", required=True, type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True)

    root = ET.Element("application")
    table = ET.SubElement(root, "component", name="ProjectJdkTable")
    add_jdk(table, "21", args.java21)
    add_jdk(table, "25", args.java25)
    write_xml(args.output, "jdk.table.xml", root)

    root = ET.Element("application")
    ui = ET.SubElement(root, "component", name="UISettings")
    for name, value in {
        "UI_DENSITY": "COMPACT",
        "SHOW_MAIN_MENU_MODE": "SEPARATE_TOOLBAR",
        "showTreeIndentGuides": "true",
        "compactTreeIndents": "true",
    }.items():
        ET.SubElement(ui, "option", name=name, value=value)
    write_xml(args.output, "ui.lnf.xml", root)

    root = ET.Element("application")
    laf = ET.SubElement(root, "component", name="LafManager", autodetect="false")
    ET.SubElement(laf, "laf", themeId="com.github.catppuccin.mocha.jetbrains")
    write_xml(args.output, "laf.xml", root)

    root = ET.Element("application")
    colors = ET.SubElement(root, "component", name="EditorColorsManagerImpl")
    ET.SubElement(colors, "global_color_scheme", name="Catppuccin Mocha")
    write_xml(args.output, "editorColors.xml", root)


if __name__ == "__main__":
    main()
