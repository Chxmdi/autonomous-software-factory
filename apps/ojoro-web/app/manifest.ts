import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Ojoro",
    short_name: "Ojoro",
    description: "A social operating system for physical activity.",
    start_url: "/home",
    display: "standalone",
    background_color: "#f6f3ec",
    theme_color: "#f35a1f"
  };
}
