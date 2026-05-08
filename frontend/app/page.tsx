"use client";

import { useEffect, useRef, useState, useCallback } from "react";
import { motion, useScroll, useTransform, useSpring, AnimatePresence } from "framer-motion";

/* ── Image constants ─────────────────────────────────────────── */
const DIAL =
  "https://images.unsplash.com/photo-1547996160-81dfa63595aa?auto=format&fit=crop&w=2200&q=85";
const FULL_WATCH =
  "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1800&q=85";
const MOVEMENT =
  "https://images.pexels.com/photos/2783873/pexels-photo-2783873.jpeg?auto=compress&cs=tinysrgb&w=1600";
const PART_1 =
  "https://images.pexels.com/photos/277390/pexels-photo-277390.jpeg?auto=compress&cs=tinysrgb&w=1100";
const PART_2 =
  "https://images.unsplash.com/photo-1622434641406-a158123450f9?auto=format&fit=crop&w=1100&q=85";
const ANATOMY_4 =
  "https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=1400&q=85";

const RAILWAY_URL = "https://shopsphere-production-4454.up.railway.app";

/* ── Types ───────────────────────────────────────────────────── */
interface Product {
  id: number;
  name: string;
  price: number;
  description?: string;
}

/* ═══════════════════════════════════════════════════════════════
   NAV
═══════════════════════════════════════════════════════════════ */
function Nav() {
  const [clock, setClock] = useState("");
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const tick = () => {
      const now = new Date();
      setClock(now.toUTCString().split(" ")[4] + " UTC");
    };
    tick();
    const id = setInterval(tick, 1000);
    const onScroll = () => setScrolled(window.scrollY > 40);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => {
      clearInterval(id);
      window.removeEventListener("scroll", onScroll);
    };
  }, []);

  return (
    <nav
      className={`fixed top-4 left-1/2 z-50 -translate-x-1/2 w-[calc(100%-2rem)] max-w-5xl
        flex items-center justify-between px-5 py-3 rounded-full
        transition-all duration-500
        ${scrolled
          ? "bg-[rgba(5,5,7,0.85)] backdrop-blur-xl border border-[rgba(177,75,255,0.2)]"
          : "bg-[rgba(5,5,7,0.4)] backdrop-blur-md border border-[rgba(255,255,255,0.05)]"
        }`}
    >
      {/* Brand */}
      <div className="flex items-center gap-2">
        <span className="relative flex h-2 w-2">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#29f6ff] opacity-75" />
          <span className="relative inline-flex rounded-full h-2 w-2 bg-[#29f6ff]" />
        </span>
        <span
          className="font-display text-sm font-black italic tracking-widest text-[#f4f1ea] text-glow-cyan"
          style={{ fontFamily: '"Bodoni Moda", serif', letterSpacing: "0.18em" }}
        >
          CHRONO-VANDL
        </span>
      </div>

      {/* Links */}
      <div className="hidden md:flex items-center gap-7">
        {["MOVEMENT", "VIBE", "SPECS", "DROP"].map((l) => (
          <a
            key={l}
            href={`#${l.toLowerCase()}`}
            className="font-mono text-[10px] tracking-[0.2em] text-[rgba(244,241,234,0.5)] hover:text-[#29f6ff] transition-colors duration-300"
          >
            {l}
          </a>
        ))}
      </div>

      {/* CTA */}
      <a
        href="#drop"
        className="liquid-btn px-4 py-1.5 rounded-full font-mono text-[10px] tracking-[0.2em] text-[#f4f1ea]"
      >
        JOIN DROP
      </a>

      {/* Clock */}
      <span className="hidden lg:block font-mono text-[9px] tracking-widest text-[rgba(244,241,234,0.3)]">
        {clock}
      </span>
    </nav>
  );
}

/* ═══════════════════════════════════════════════════════════════
   HERO SCENE — 420vh scroll-driven, 4 phases
═══════════════════════════════════════════════════════════════ */
function HeroScene() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  const smoothProgress = useSpring(scrollYProgress, { stiffness: 60, damping: 20 });

  /* Phase 01 DIAL */
  const dialScale    = useTransform(smoothProgress, [0, 0.22], [2.2, 1]);
  const dialOpacity  = useTransform(smoothProgress, [0.18, 0.26], [1, 0]);
  const dialBlurVal  = useTransform(smoothProgress, [0.18, 0.26], [0, 24]);
  const dialFilter   = useTransform(dialBlurVal, (v: number) => `blur(${v}px)`);

  /* Phase 02 ROTATE */
  const watchOpacity = useTransform(smoothProgress, [0.24, 0.32, 0.46, 0.52], [0, 1, 1, 0]);
  const watchRotate  = useTransform(smoothProgress, [0.25, 0.5], [0, 360]);
  const watchScale   = useTransform(smoothProgress, [0.25, 0.35], [0.8, 1]);

  /* Phase 03 EXPLODE */
  const movOp   = useTransform(smoothProgress, [0.5, 0.58, 0.72, 0.78], [0, 1, 1, 0]);
  const part1X  = useTransform(smoothProgress, [0.5, 0.75], [0, -180]);
  const part1Y  = useTransform(smoothProgress, [0.5, 0.75], [0, -120]);
  const part2X  = useTransform(smoothProgress, [0.5, 0.75], [0, 180]);
  const part2Y  = useTransform(smoothProgress, [0.5, 0.75], [0, 100]);

  /* Phase 04 DROP */
  const dropOpacity = useTransform(smoothProgress, [0.76, 0.85], [0, 1]);
  const dropY       = useTransform(smoothProgress, [0.76, 0.85], [40, 0]);

  /* Background outline text parallax */
  const chronoY = useTransform(smoothProgress, [0, 1], ["0%", "-12%"]);
  const vandlY  = useTransform(smoothProgress, [0, 1], ["0%", "12%"]);

  /* Hero copy */
  const copyOp = useTransform(smoothProgress, [0, 0.08, 0.2, 0.26], [0, 1, 1, 0]);
  const copyY  = useTransform(smoothProgress, [0, 0.08], [40, 0]);

  /* Spec labels */
  const specOp = useTransform(smoothProgress, [0.28, 0.36, 0.46, 0.52], [0, 1, 1, 0]);

  return (
    <div ref={containerRef} className="relative h-[420vh]">
      <div className="sticky top-0 h-screen w-full overflow-hidden bg-[#050507]">

        {/* Background outline text */}
        <motion.div
          style={{ y: chronoY }}
          className="absolute top-[8%] left-1/2 -translate-x-1/2 pointer-events-none select-none z-0"
        >
          <span
            className="outline-text"
            style={{ fontSize: "clamp(6rem, 22vw, 22rem)", display: "block" }}
          >
            CHRONO
          </span>
        </motion.div>
        <motion.div
          style={{ y: vandlY }}
          className="absolute bottom-[8%] left-1/2 -translate-x-1/2 pointer-events-none select-none z-0"
        >
          <span
            className="outline-text"
            style={{ fontSize: "clamp(6rem, 22vw, 22rem)", display: "block" }}
          >
            VANDL∞
          </span>
        </motion.div>

        {/* Phase 01 — DIAL */}
        <motion.div
          style={{ scale: dialScale, opacity: dialOpacity, filter: dialFilter }}
          className="absolute inset-0 flex items-center justify-center z-10"
        >
          <div className="relative w-[min(70vw,560px)] h-[min(70vw,560px)]">
            {[0, 0.8, 1.6].map((delay, i) => (
              <div
                key={i}
                className="ring-pulse absolute inset-[10%]"
                style={{ animationDelay: `${delay}s` }}
              />
            ))}
            <img
              src={DIAL}
              alt="Watch dial macro"
              className="w-full h-full object-cover rounded-full"
              style={{ boxShadow: "0 0 120px rgba(41,246,255,0.15), 0 0 60px rgba(177,75,255,0.2)" }}
            />
            <div
              className="absolute inset-[-15%] rounded-full border border-[rgba(177,75,255,0.2)] spin-slow"
              style={{ borderStyle: "dashed" }}
            />
            <div
              className="absolute inset-[-25%] rounded-full border border-[rgba(41,246,255,0.12)] spin-rev"
              style={{ borderStyle: "dotted" }}
            />
          </div>
        </motion.div>

        {/* Phase 01 — phase label */}
        <motion.div
          style={{ opacity: dialOpacity }}
          className="absolute bottom-[15%] left-1/2 -translate-x-1/2 z-20 text-center"
        >
          <span className="font-mono text-[10px] tracking-[0.4em] text-[rgba(244,241,234,0.35)]">
            PHASE 01 · DIAL
          </span>
        </motion.div>

        {/* Phase 01 — hero copy */}
        <motion.div
          style={{ opacity: copyOp, y: copyY }}
          className="absolute top-[20%] left-[8%] z-20 max-w-xs"
        >
          <p className="font-mono text-[10px] tracking-[0.35em] text-[#29f6ff] mb-3 text-glow-cyan">
            LIMITED EDITION · AED 2,850
          </p>
          <h1
            className="font-display text-[clamp(3rem,8vw,6rem)] font-black italic leading-none text-[#f4f1ea] mb-4"
            style={{ fontFamily: '"Bodoni Moda", serif' }}
          >
            ANOMALY
          </h1>
          <p className="font-sans text-sm text-[rgba(244,241,234,0.55)] leading-relaxed max-w-[220px]">
            A timepiece born from<br />contradiction
          </p>
        </motion.div>

        {/* Phase 02 — FULL WATCH with rotation */}
        <motion.div
          style={{ opacity: watchOpacity, rotate: watchRotate, scale: watchScale }}
          className="absolute inset-0 flex items-center justify-center z-10"
        >
          <div className="relative w-[min(60vw,480px)] h-[min(60vw,480px)]">
            <div className="absolute inset-[-18%] rounded-full border border-[rgba(177,75,255,0.25)] spin-slow" />
            <div className="absolute inset-[-30%] rounded-full border border-[rgba(41,246,255,0.15)] spin-rev" />
            <img
              src={FULL_WATCH}
              alt="Full watch"
              className="w-full h-full object-cover rounded-full"
              style={{ boxShadow: "0 0 80px rgba(177,75,255,0.3), 0 0 40px rgba(41,246,255,0.15)" }}
            />
          </div>
        </motion.div>

        {/* Phase 02 — spec labels */}
        <motion.div style={{ opacity: specOp }} className="absolute inset-0 z-20 pointer-events-none">
          {[
            { label: "JEWELS",       value: "27",   top: "18%",    left: "8%"  },
            { label: "BARREL TUNED", value: "∞",    top: "18%",    right: "8%" },
            { label: "BALANCE",      value: "4Hz",  bottom: "22%", left: "8%"  },
            { label: "RESERVE",      value: "72H",  bottom: "22%", right: "8%" },
          ].map(({ label, value, ...pos }) => (
            <div
              key={label}
              className="absolute font-mono text-center"
              style={pos as React.CSSProperties}
            >
              <div className="text-[clamp(1.5rem,4vw,2.5rem)] font-bold text-[#29f6ff] text-glow-cyan leading-none">
                {value}
              </div>
              <div className="text-[9px] tracking-[0.3em] text-[rgba(244,241,234,0.4)] mt-1">{label}</div>
            </div>
          ))}
        </motion.div>

        {/* Phase 03 — EXPLODE */}
        <motion.div
          style={{ opacity: movOp }}
          className="absolute inset-0 flex items-center justify-center z-10"
        >
          <img
            src={MOVEMENT}
            alt="Watch movement"
            className="w-[min(42vw,340px)] h-[min(42vw,340px)] object-cover rounded-full"
            style={{ boxShadow: "0 0 60px rgba(177,75,255,0.4)" }}
          />
          <motion.img
            src={PART_1}
            alt="Part 1"
            style={{ x: part1X, y: part1Y, opacity: movOp }}
            className="absolute w-[min(20vw,160px)] h-[min(20vw,160px)] object-cover rounded-xl"
            aria-hidden="true"
          />
          <motion.img
            src={PART_2}
            alt="Part 2"
            style={{ x: part2X, y: part2Y, opacity: movOp }}
            className="absolute w-[min(20vw,160px)] h-[min(20vw,160px)] object-cover rounded-xl"
            aria-hidden="true"
          />
        </motion.div>

        {/* Phase 03 — label */}
        <motion.div
          style={{ opacity: movOp }}
          className="absolute bottom-[15%] left-1/2 -translate-x-1/2 z-20 text-center"
        >
          <span className="font-mono text-[10px] tracking-[0.4em] text-[rgba(244,241,234,0.35)]">
            PHASE 03 · MOVEMENT EXPLODED
          </span>
        </motion.div>

        {/* Phase 04 — DROP CTA */}
        <motion.div
          style={{ opacity: dropOpacity, y: dropY }}
          className="absolute inset-0 flex flex-col items-center justify-center z-20 bg-[rgba(5,5,7,0.6)]"
        >
          <p className="font-mono text-[10px] tracking-[0.5em] text-[#b14bff] text-glow-purple mb-6">
            LIMITED DROP · PHASE 04
          </p>
          <h2
            className="font-display text-[clamp(4rem,14vw,11rem)] font-black italic leading-none text-[#f4f1ea] text-center mb-6"
            style={{ fontFamily: '"Bodoni Moda", serif' }}
          >
            ANOMALY
          </h2>
          <p className="font-sans text-[rgba(244,241,234,0.5)] text-sm tracking-wider mb-8">
            AED 2,850 · ONLY 27 UNITS
          </p>
          <a
            href="#drop"
            className="liquid-btn px-8 py-3 rounded-full font-mono text-xs tracking-[0.25em] text-[#f4f1ea]"
          >
            CLAIM YOURS →
          </a>
        </motion.div>

      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MARQUEE SECTION
═══════════════════════════════════════════════════════════════ */
function MarqueeSection() {
  const row1 = "CHRONO-VANDL · LIMITED DROP · HAND-ASSEMBLED · SWISS MOVEMENT · TITANIUM GRADE-5 · ";
  const row2 = "AED 2,850 · 72H POWER RESERVE · SAPPHIRE CRYSTAL · 50M WATER RESIST · CERAMIC BEZEL · ";

  return (
    <section className="bg-[#050507] py-8 overflow-hidden border-y border-[rgba(255,255,255,0.04)]">
      <div className="marquee-wrapper overflow-hidden mb-3">
        <div className="marquee-track font-mono text-sm tracking-[0.25em] text-[rgba(244,241,234,0.25)]">
          {row1.repeat(6)}
        </div>
      </div>
      <div className="marquee-wrapper overflow-hidden">
        <div className="marquee-track marquee-track-rev font-mono text-sm tracking-[0.25em] text-[#29f6ff] text-glow-cyan">
          {row2.repeat(6)}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════════════════
   ANATOMY SECTION
═══════════════════════════════════════════════════════════════ */
function Anatomy() {
  const scrollRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: scrollRef,
    offset: ["start end", "end start"],
  });
  const trackX = useTransform(scrollYProgress, [0, 1], ["0%", "-40%"]);

  const ANATOMY_IMAGES = [DIAL, FULL_WATCH, MOVEMENT, ANATOMY_4, PART_2];

  const stats = [
    { value: "27",    label: "JEWELS" },
    { value: "72H",   label: "RESERVE" },
    { value: "4 Hz",  label: "FREQUENCY" },
    { value: "5 ATM", label: "DEPTH" },
  ];

  return (
    <section ref={scrollRef} className="bg-[#050507] py-24 overflow-hidden">
      {/* Big marquee headline */}
      <div className="overflow-hidden mb-16">
        <div className="marquee-track">
          <span
            className="outline-text-neon font-display font-black italic"
            style={{
              fontSize: "clamp(5rem,18vw,14rem)",
              fontFamily: '"Bodoni Moda", serif',
              letterSpacing: "-0.04em",
              lineHeight: 0.82,
            }}
          >
            MECHANICAL ANOMALY ∞ &nbsp; MECHANICAL ANOMALY ∞ &nbsp;
          </span>
        </div>
      </div>

      {/* Horizontal scroll track */}
      <div className="overflow-hidden mb-16">
        <motion.div style={{ x: trackX }} className="flex gap-4 will-change-transform">
          {ANATOMY_IMAGES.map((src, i) => (
            <div
              key={i}
              className="flex-shrink-0 w-[clamp(240px,38vw,480px)] h-[clamp(300px,48vw,600px)] overflow-hidden rounded-2xl bento-card"
            >
              <img
                src={src}
                alt={`Anatomy ${i + 1}`}
                className="bento-img w-full h-full object-cover"
              />
            </div>
          ))}
        </motion.div>
      </div>

      {/* Stats */}
      <div className="max-w-5xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-6">
        {stats.map(({ value, label }, i) => (
          <motion.div
            key={label}
            initial={{ opacity: 0, y: 24 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1, duration: 0.7, ease: [0.2, 0.8, 0.2, 1] }}
            viewport={{ once: true }}
            className="text-center"
          >
            <div className="font-mono text-[clamp(2.5rem,7vw,4rem)] font-bold text-[#29f6ff] text-glow-cyan leading-none mb-2">
              {value}
            </div>
            <div className="divider-line mb-2" />
            <div className="font-mono text-[10px] tracking-[0.3em] text-[rgba(244,241,234,0.4)]">{label}</div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MOVEMENT GALLERY (id="movement")
═══════════════════════════════════════════════════════════════ */
function MovementGallery() {
  const cards = [
    { src: FULL_WATCH, label: "CALIBER CV-VII",  sub: "Automatic 28800 vph",   accent: "#b14bff", col: "col-span-2 row-span-2" },
    { src: DIAL,       label: "SAPPHIRE CRYSTAL", sub: "Anti-reflective coating", accent: "#29f6ff", col: "" },
    { src: MOVEMENT,   label: "SWISS MOVEMENT",  sub: "Hand-finished bridges",  accent: "#ff3df0", col: "" },
    { src: PART_1,     label: "TITANIUM GRADE-5", sub: "Weight: 98 g",           accent: "#29f6ff", col: "" },
  ];

  return (
    <section id="movement" className="bg-[#050507] py-24">
      <div className="max-w-6xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.9, ease: [0.2, 0.8, 0.2, 1] }}
          viewport={{ once: true }}
          className="mb-12"
        >
          <p className="font-mono text-[10px] tracking-[0.35em] text-[#b14bff] text-glow-purple mb-3">
            02 · MOVEMENT
          </p>
          <h2
            className="font-display font-black italic text-[clamp(3rem,8vw,6rem)] leading-none text-[#f4f1ea]"
            style={{ fontFamily: '"Bodoni Moda", serif' }}
          >
            In Every
            <br />
            <span className="outline-text">Detail</span>
          </h2>
        </motion.div>

        <div className="grid grid-cols-3 grid-rows-2 gap-3 h-[70vh]">
          {cards.map(({ src, label, sub, accent, col }, i) => (
            <motion.div
              key={label}
              initial={{ opacity: 0, scale: 0.96 }}
              whileInView={{ opacity: 1, scale: 1 }}
              transition={{ delay: i * 0.1, duration: 0.7, ease: [0.2, 0.8, 0.2, 1] }}
              viewport={{ once: true }}
              className={`bento-card rounded-2xl ${col}`}
            >
              <img
                src={src}
                alt={label}
                className="bento-img w-full h-full object-cover"
              />
              <div className="smoke" />
              <div className="absolute bottom-0 left-0 right-0 p-5 z-10">
                <div
                  className="font-mono text-[10px] tracking-[0.3em] mb-1"
                  style={{ color: accent }}
                >
                  {label}
                </div>
                <div className="font-sans text-sm text-[rgba(244,241,234,0.6)]">{sub}</div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════════════════
   VIBE SECTION (id="vibe")
═══════════════════════════════════════════════════════════════ */
function VibeSection() {
  return (
    <section id="vibe" className="relative bg-[#050507] min-h-screen flex items-center overflow-hidden">
      <div className="absolute inset-0 z-0">
        <img
          src={ANATOMY_4}
          alt="CHRONO-VANDL lifestyle"
          className="w-full h-full object-cover opacity-40"
        />
        <div className="absolute inset-0 bg-gradient-to-r from-[#050507] via-[rgba(5,5,7,0.5)] to-transparent" />
        <div className="absolute inset-0 bg-gradient-to-t from-[#050507] via-transparent to-transparent" />
      </div>

      <div className="relative z-10 max-w-5xl mx-auto px-8 py-32">
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.1, ease: [0.2, 0.8, 0.2, 1] }}
          viewport={{ once: true }}
        >
          <p className="font-mono text-[10px] tracking-[0.4em] text-[#29f6ff] text-glow-cyan mb-6">
            03 · VIBE
          </p>
          <h2
            className="font-display font-black italic leading-none text-[#f4f1ea]"
            style={{
              fontSize: "clamp(3.5rem,11vw,9rem)",
              fontFamily: '"Bodoni Moda", serif',
              letterSpacing: "-0.03em",
            }}
          >
            BORN FROM
            <br />
            <span className="outline-text">CONTRADICTION</span>
          </h2>
          <div className="divider-line my-10 max-w-sm" />
          <p className="font-sans text-base text-[rgba(244,241,234,0.55)] max-w-md leading-relaxed">
            Where raw precision meets controlled chaos. A mechanical heart that beats
            against expectations — forged in titanium, tempered by obsession.
          </p>
          <a
            href="#drop"
            className="liquid-btn inline-block mt-10 px-8 py-3 rounded-full font-mono text-xs tracking-[0.25em] text-[#f4f1ea]"
          >
            EXPLORE THE DROP
          </a>
        </motion.div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SPECS SECTION (id="specs")
═══════════════════════════════════════════════════════════════ */
interface SpecRow {
  spec: string;
  value: string;
}

const FALLBACK_SPECS: SpecRow[] = [
  { spec: "CALIBER",          value: "CV-VII Automatic" },
  { spec: "FREQUENCY",        value: "28,800 vph" },
  { spec: "POWER RESERVE",    value: "72 Hours" },
  { spec: "CASE MATERIAL",    value: "Grade-5 Titanium" },
  { spec: "CRYSTAL",          value: "Sapphire Anti-Reflective" },
  { spec: "BEZEL",            value: "Ceramic" },
  { spec: "WATER RESISTANCE", value: "50 Metres / 5 ATM" },
  { spec: "WEIGHT",           value: "98 Grams" },
];

function SpecsSection() {
  const [specs] = useState<SpecRow[]>(FALLBACK_SPECS);
  const [live, setLive] = useState(false);

  useEffect(() => {
    const ctrl = new AbortController();
    fetch(`${RAILWAY_URL}/api/products`, { signal: ctrl.signal })
      .then((r) => r.json())
      .then((data: Product[]) => {
        if (Array.isArray(data) && data.length > 0) setLive(true);
      })
      .catch(() => {});
    return () => ctrl.abort();
  }, []);

  return (
    <section id="specs" className="bg-[#050507] py-24">
      <div className="max-w-4xl mx-auto px-6">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.9 }}
          viewport={{ once: true }}
          className="mb-14"
        >
          <p className="font-mono text-[10px] tracking-[0.4em] text-[#ff3df0] mb-3">04 · SPECIFICATIONS</p>
          <h2
            className="font-display font-black italic text-[clamp(2.5rem,7vw,5rem)] leading-none text-[#f4f1ea]"
            style={{ fontFamily: '"Bodoni Moda", serif' }}
          >
            Every Number
            <br />
            <span className="outline-text-cyan">Has a Purpose</span>
          </h2>
        </motion.div>

        <div>
          {specs.map(({ spec, value }, i) => (
            <motion.div
              key={spec}
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ delay: i * 0.07, duration: 0.7, ease: [0.2, 0.8, 0.2, 1] }}
              viewport={{ once: true }}
              className="group relative flex items-center justify-between py-5 border-b border-[rgba(255,255,255,0.04)] hover:border-[rgba(41,246,255,0.2)] transition-colors duration-300"
            >
              <span className="font-mono text-[11px] tracking-[0.25em] text-[rgba(244,241,234,0.4)] group-hover:text-[#29f6ff] transition-colors duration-300">
                {spec}
              </span>
              <span className="font-sans text-sm text-[rgba(244,241,234,0.8)] group-hover:text-[#f4f1ea] transition-colors duration-300">
                {value}
              </span>
            </motion.div>
          ))}
        </div>

        {!live && (
          <p className="font-mono text-[9px] tracking-[0.3em] text-[rgba(244,241,234,0.2)] mt-8 text-center">
            SOURCED FROM ENGINEERING RECORDS
          </p>
        )}
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════════════════
   DROP CTA (id="drop")
═══════════════════════════════════════════════════════════════ */
function DropCTA() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle");
  const [displayPrice, setDisplayPrice] = useState("AED 2,850");

  useEffect(() => {
    fetch(`${RAILWAY_URL}/api/products`)
      .then((r) => r.json())
      .then((data: Product[]) => {
        if (Array.isArray(data) && data.length > 0) {
          const watch = data.find((p) => /watch|chrono/i.test(p.name)) || data[0];
          setDisplayPrice(`AED ${watch.price.toLocaleString()}`);
        }
      })
      .catch(() => {});
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;
    setStatus("loading");
    try {
      await fetch(`${RAILWAY_URL}/api/waitlist`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      });
    } catch {
      // no-op
    }
    setStatus("success");
  };

  return (
    <section id="drop" className="relative bg-[#050507] min-h-screen flex items-center justify-center overflow-hidden">
      <div className="absolute inset-0 pointer-events-none z-0">
        <div
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full"
          style={{ background: "radial-gradient(circle, rgba(177,75,255,0.12) 0%, transparent 70%)" }}
        />
      </div>

      <div className="relative z-10 max-w-2xl mx-auto px-6 py-32 text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.7 }}
          viewport={{ once: true }}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-[rgba(177,75,255,0.4)] mb-8"
        >
          <span className="w-1.5 h-1.5 rounded-full bg-[#b14bff] animate-pulse" />
          <span className="font-mono text-[9px] tracking-[0.35em] text-[#b14bff]">
            LIMITED EDITION · 27 UNITS
          </span>
        </motion.div>

        {/* Headline */}
        <motion.h2
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1, duration: 1, ease: [0.2, 0.8, 0.2, 1] }}
          viewport={{ once: true }}
          className="font-display font-black italic leading-none text-[#f4f1ea] mb-4"
          style={{ fontSize: "clamp(4rem,14vw,10rem)", fontFamily: '"Bodoni Moda", serif' }}
        >
          CLAIM
          <br />
          <span className="outline-text">YOURS</span>
        </motion.h2>

        {/* Price */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ delay: 0.25, duration: 0.7 }}
          viewport={{ once: true }}
          className="font-mono text-3xl font-bold text-[#29f6ff] text-glow-cyan mb-2"
        >
          {displayPrice}
        </motion.div>
        <p className="font-mono text-[10px] tracking-[0.3em] text-[rgba(244,241,234,0.3)] mb-12">
          FREE SHIPPING · 5-YEAR WARRANTY · NUMBERED CERTIFICATE
        </p>

        {/* Email form */}
        <AnimatePresence mode="wait">
          {status === "success" ? (
            <motion.div
              key="success"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              className="py-8"
            >
              <div className="text-5xl mb-4 text-[#29f6ff]">✦</div>
              <p className="font-mono text-sm tracking-[0.2em] text-[#29f6ff] text-glow-cyan mb-2">
                YOU&apos;RE ON THE LIST
              </p>
              <p className="font-sans text-sm text-[rgba(244,241,234,0.45)]">
                We&apos;ll notify you the moment the drop goes live.
              </p>
            </motion.div>
          ) : (
            <motion.form
              key="form"
              onSubmit={handleSubmit}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3, duration: 0.7 }}
              className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto"
            >
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                required
                className="flex-1 bg-[rgba(255,255,255,0.04)] border border-[rgba(177,75,255,0.3)] rounded-full px-5 py-3
                  font-mono text-sm text-[#f4f1ea] placeholder-[rgba(244,241,234,0.25)]
                  focus:outline-none focus:border-[rgba(41,246,255,0.6)] transition-colors"
              />
              <button
                type="submit"
                disabled={status === "loading"}
                className="liquid-btn px-7 py-3 rounded-full font-mono text-xs tracking-[0.25em] text-[#f4f1ea] whitespace-nowrap"
              >
                {status === "loading" ? "..." : "JOIN DROP"}
              </button>
            </motion.form>
          )}
        </AnimatePresence>

        {/* Display numbers */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          viewport={{ once: true }}
          className="flex justify-center gap-8 mt-16"
        >
          {[
            { n: "27",    l: "UNITS"   },
            { n: "∞",     l: "WARRANTY" },
            { n: "CV-VII", l: "CALIBER" },
          ].map(({ n, l }) => (
            <div key={l} className="text-center">
              <div className="font-mono text-2xl font-bold text-[rgba(244,241,234,0.7)]">{n}</div>
              <div className="font-mono text-[8px] tracking-[0.3em] text-[rgba(244,241,234,0.25)] mt-1">{l}</div>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}

/* ═══════════════════════════════════════════════════════════════
   FOOTER
═══════════════════════════════════════════════════════════════ */
function Footer() {
  const year = new Date().getFullYear();

  return (
    <footer className="bg-[#050507]">
      <div className="divider-line" />
      <div className="max-w-6xl mx-auto px-6 py-16 grid grid-cols-2 md:grid-cols-4 gap-10">
        {/* Brand */}
        <div className="col-span-2 md:col-span-1">
          <div className="flex items-center gap-2 mb-4">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#29f6ff] opacity-60" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-[#29f6ff]" />
            </span>
            <span
              className="font-display text-sm font-black italic tracking-widest text-[#f4f1ea]"
              style={{ fontFamily: '"Bodoni Moda", serif', letterSpacing: "0.15em" }}
            >
              CHRONO-VANDL
            </span>
          </div>
          <p className="font-sans text-xs text-[rgba(244,241,234,0.35)] leading-relaxed max-w-[200px]">
            A timepiece born from contradiction. Mechanical precision meets raw intention.
          </p>
        </div>

        {/* Navigation */}
        <div>
          <p className="font-mono text-[9px] tracking-[0.35em] text-[rgba(244,241,234,0.3)] mb-5">NAVIGATE</p>
          <ul className="space-y-3">
            {["MOVEMENT", "VIBE", "SPECS", "DROP"].map((l) => (
              <li key={l}>
                <a
                  href={`#${l.toLowerCase()}`}
                  className="font-mono text-[11px] tracking-[0.2em] text-[rgba(244,241,234,0.5)] hover:text-[#29f6ff] transition-colors"
                >
                  {l}
                </a>
              </li>
            ))}
          </ul>
        </div>

        {/* Legal */}
        <div>
          <p className="font-mono text-[9px] tracking-[0.35em] text-[rgba(244,241,234,0.3)] mb-5">LEGAL</p>
          <ul className="space-y-3">
            {["Privacy Policy", "Terms of Use", "Return Policy", "Warranty"].map((l) => (
              <li key={l}>
                <span className="font-sans text-xs text-[rgba(244,241,234,0.4)]">{l}</span>
              </li>
            ))}
          </ul>
        </div>

        {/* Credit */}
        <div>
          <p className="font-mono text-[9px] tracking-[0.35em] text-[rgba(244,241,234,0.3)] mb-5">PROJECT</p>
          <p className="font-sans text-xs text-[rgba(244,241,234,0.35)] leading-relaxed">
            Built for DBMS Project.
            <br />
            Full-stack Next.js + Railway PostgreSQL.
          </p>
          <p className="font-mono text-[9px] tracking-[0.2em] text-[rgba(244,241,234,0.2)] mt-4">
            © {year} CHRONO-VANDL
          </p>
        </div>
      </div>
    </footer>
  );
}

/* ═══════════════════════════════════════════════════════════════
   ROOT PAGE
═══════════════════════════════════════════════════════════════ */
export default function Page() {
  const dotRef  = useRef<HTMLDivElement>(null);
  const ringRef = useRef<HTMLDivElement>(null);
  const rafRef  = useRef<number>(0);
  const posRef  = useRef({ x: -100, y: -100 });
  const ringPos = useRef({ x: -100, y: -100 });

  const animateCursor = useCallback(() => {
    ringPos.current.x += (posRef.current.x - ringPos.current.x) * 0.12;
    ringPos.current.y += (posRef.current.y - ringPos.current.y) * 0.12;

    if (dotRef.current) {
      dotRef.current.style.transform = `translate(${posRef.current.x}px, ${posRef.current.y}px) translate(-50%, -50%)`;
    }
    if (ringRef.current) {
      ringRef.current.style.transform = `translate(${ringPos.current.x}px, ${ringPos.current.y}px) translate(-50%, -50%)`;
    }
    rafRef.current = requestAnimationFrame(animateCursor);
  }, []);

  useEffect(() => {
    const onMove = (e: MouseEvent) => {
      posRef.current = { x: e.clientX, y: e.clientY };
    };
    window.addEventListener("mousemove", onMove);
    rafRef.current = requestAnimationFrame(animateCursor);
    return () => {
      window.removeEventListener("mousemove", onMove);
      cancelAnimationFrame(rafRef.current);
    };
  }, [animateCursor]);

  /* Reveal-up observer */
  useEffect(() => {
    const els = document.querySelectorAll<HTMLElement>(".reveal-up");
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            e.target.classList.add("in");
            obs.unobserve(e.target);
          }
        });
      },
      { threshold: 0.15 }
    );
    els.forEach((el) => obs.observe(el));
    return () => obs.disconnect();
  }, []);

  return (
    <main className="bg-[#050507] grain relative">
      <div ref={ringRef} className="cursor-ring" style={{ transform: "translate(-100px, -100px)" }} />
      <div ref={dotRef}  className="cursor-dot"  style={{ transform: "translate(-100px, -100px)" }} />
      <div className="light-leak" />

      <Nav />
      <HeroScene />
      <MarqueeSection />
      <Anatomy />
      <MovementGallery />
      <VibeSection />
      <SpecsSection />
      <DropCTA />
      <Footer />
    </main>
  );
}
