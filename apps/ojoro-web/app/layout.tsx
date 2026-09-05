import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Ojoro — Go do something", template: "%s · Ojoro" },
  description: "Find people, clans and real-world activities. Show up, progress and build your sports story.",
  applicationName: "Ojoro"
};

export const viewport: Viewport = {
  themeColor: "#f35a1f",
  width: "device-width",
  initialScale: 1,
  viewportFit: "cover"
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
