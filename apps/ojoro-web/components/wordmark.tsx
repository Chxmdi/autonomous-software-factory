import Link from "next/link";

export function Wordmark({ href = "/" }: { href?: string }) {
  return <Link className="wordmark" href={href} aria-label="Ojoro home"><span className="wordmark-mark">O</span><span>OJORO</span></Link>;
}
