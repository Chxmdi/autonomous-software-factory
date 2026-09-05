import Link from "next/link";
import { ArrowUpRight, MapPin, ShieldCheck, Sparkles, Users, Zap } from "lucide-react";
import { Wordmark } from "@/components/wordmark";

export default function LandingPage() {
  return (
    <main className="landing-shell">
      <nav className="landing-nav" aria-label="Primary">
        <Wordmark />
        <div className="landing-nav-actions">
          <Link className="button button-ghost" href="/login">Sign in</Link>
          <Link className="button button-dark" href="/login?mode=signup">Join Ojoro</Link>
        </div>
      </nav>

      <section className="hero-grid">
        <div className="hero-copy">
          <div className="eyebrow"><Zap size={14} /> Your city is your gym</div>
          <h1>Go do <em>something.</em></h1>
          <p className="hero-lede">Find a game, join a clan, try a new sport, or rally people around an activity. Ojoro turns movement into a social life.</p>
          <div className="hero-actions">
            <Link className="button button-brand button-lg" href="/login?mode=signup">Find your people <ArrowUpRight size={18} /></Link>
            <a className="text-link" href="#how">See how it works</a>
          </div>
          <div className="trust-strip" aria-label="Ojoro principles">
            <span><ShieldCheck size={16} /> Behavior-based trust</span>
            <span><Users size={16} /> Social or competitive</span>
            <span><MapPin size={16} /> Local first</span>
          </div>
        </div>

        <div className="hero-stage" aria-label="Preview of Ojoro activity discovery">
          <div className="stage-orbit stage-orbit-a" />
          <div className="stage-orbit stage-orbit-b" />
          <article className="hero-card hero-card-main">
            <div className="card-kicker"><span className="live-dot" /> STARTS IN 42 MIN</div>
            <div className="sport-icon">⚽</div>
            <h2>Friday night 7v7</h2>
            <p>Jeanne-Mance · Social / Intermediate</p>
            <div className="hero-card-row"><strong>11 / 14</strong><span>3 spots left</span></div>
            <button type="button" className="button button-dark button-full">I’m in</button>
          </article>
          <article className="floating-card floating-card-top">
            <span className="floating-icon">🏃</span>
            <div><small>CLAN PULSE</small><strong>8 people free tonight</strong></div>
          </article>
          <article className="floating-card floating-card-bottom">
            <span className="floating-icon">🏆</span>
            <div><small>YOUR WEEK</small><strong>2 / 3 activities</strong></div>
          </article>
        </div>
      </section>

      <section className="principle-band" id="how">
        <p>DISCOVER</p><span>→</span><p>SHOW UP</p><span>→</span><p>PROGRESS</p><span>→</span><p>MEET PEOPLE</p><span>→</span><p>REPEAT</p>
      </section>

      <section className="landing-section">
        <div className="section-heading"><div className="eyebrow"><Sparkles size={14} /> Built around action</div><h2>Less scrolling.<br />More stories you actually lived.</h2></div>
        <div className="feature-grid">
          <article><span>01</span><h3>What can I do?</h3><p>See joinable games, sessions and events happening soon—filtered by your sports, level, time and city.</p></article>
          <article><span>02</span><h3>Who can I do it with?</h3><p>Join multi-sport clans, teams and people who share your schedule and how you like to move.</p></article>
          <article><span>03</span><h3>How am I progressing?</h3><p>Your profile becomes a sports résumé: consistency, new sports, achievements, records and community contribution.</p></article>
          <article><span>04</span><h3>How do I compare?</h3><p>Opt into trustworthy sport ratings, seasonal leaderboards and clan competition—or keep competition quiet.</p></article>
        </div>
      </section>
    </main>
  );
}
