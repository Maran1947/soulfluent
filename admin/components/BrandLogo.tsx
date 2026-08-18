import Image from "next/image";

export default function BrandLogo({ size = "md" }: { size?: "sm" | "md" | "lg" }) {
  const iconDimensions =
    size === "sm"
      ? { box: "w-8 h-8", px: 32 }
      : size === "lg"
      ? { box: "w-12 h-12", px: 48 }
      : { box: "w-10 h-10", px: 40 };

  const textSize = size === "sm" ? "text-base" : size === "lg" ? "text-2xl" : "text-xl";

  return (
    <div className="flex items-center gap-2.5 select-none">
      <div className={`${iconDimensions.box} relative shrink-0`}>
        <Image
          src="/logo.png"
          alt="FluentSoul Logo"
          width={iconDimensions.px}
          height={iconDimensions.px}
          className="object-contain w-full h-full"
          priority
        />
      </div>
      <span className={`${textSize} font-extrabold tracking-tight leading-none`}>
        <span className="text-slate-900 dark:text-white">Fluent</span>
        <span className="text-[#f25c40]">Soul</span>
      </span>
    </div>
  );
}
