import { useEffect, useMemo, memo } from "react";
import { create } from "zustand";
import { useShallow } from "zustand/react/shallow";

import { fetchNui } from "@app/utils/fetchNui";
import { cn } from "@app/utils";
import { hexToRgba } from "@app/utils/colors";
import { useVisibility } from "@app/stores/Visibility";
import { useImageValidation } from "@app/hooks/useImageValidation";

import fallbackAvatar from "@views/assets/images/fallback-avatar.png";

// ── Types ────────────────────────────────────────────────────────────────────

interface RankPlayer {
  id: number;
  name: string;
  avatar: string;
  boxsBuyed: number;
  rank: number;
}

type Period = "all" | "weekly" | "montlhy";

interface RankingState {
  selectedPeriod: Period;
  rank: RankPlayer[];
  setSelectedPeriod: (period: Period) => Promise<void>;
}

// ── Constants ────────────────────────────────────────────────────────────────

const RANK_COLORS: Record<number, string> = {
  1: "#F5BD16",
  2: "#C0C0C0",
  3: "#CD7F32",
};

// ── Store ────────────────────────────────────────────────────────────────────

const useRankingStore = create<RankingState>()((set) => ({
  selectedPeriod: "all",
  rank: [],

  async setSelectedPeriod(period) {
    const mockData = [
      { id: 1, name: "Tony Soprano", avatar: "https://i.pravatar.cc/150?img=12", boxsBuyed: 247 },
      { id: 2, name: "Maria Silva", avatar: "https://i.pravatar.cc/150?img=47", boxsBuyed: 189 },
      { id: 3, name: "Carlos Mendes", avatar: "https://i.pravatar.cc/150?img=33", boxsBuyed: 156 },
      { id: 4, name: "Lúcia Oliveira", avatar: "https://i.pravatar.cc/150?img=20", boxsBuyed: 142 },
      { id: 5, name: "Ricardo Santos", avatar: "https://i.pravatar.cc/150?img=68", boxsBuyed: 138 },
      { id: 6, name: "Ana Costa", avatar: "https://i.pravatar.cc/150?img=38", boxsBuyed: 127 },
      { id: 7, name: "Bruno Almeida", avatar: "https://i.pravatar.cc/150?img=52", boxsBuyed: 119 },
      { id: 8, name: "Fernanda Lima", avatar: "https://i.pravatar.cc/150?img=44", boxsBuyed: 103 },
      { id: 9, name: "João Pereira", avatar: "https://i.pravatar.cc/150?img=15", boxsBuyed: 98 },
      { id: 10, name: "Patricia Rocha", avatar: "https://i.pravatar.cc/150?img=27", boxsBuyed: 87 },
      { id: 11, name: "Miguel Torres", avatar: "https://i.pravatar.cc/150?img=59", boxsBuyed: 76 },
      { id: 12, name: "Camila Dias", avatar: "https://i.pravatar.cc/150?img=31", boxsBuyed: 71 },
      { id: 13, name: "Rafael Souza", avatar: "https://i.pravatar.cc/150?img=70", boxsBuyed: 68 },
      { id: 14, name: "Juliana Martins", avatar: "https://i.pravatar.cc/150?img=23", boxsBuyed: 62 },
      { id: 15, name: "Pedro Barbosa", avatar: "https://i.pravatar.cc/150?img=61", boxsBuyed: 54 },
      { id: 16, name: "Beatriz Castro", avatar: "https://i.pravatar.cc/150?img=36", boxsBuyed: 49 },
      { id: 17, name: "Thiago Ramos", avatar: "https://i.pravatar.cc/150?img=56", boxsBuyed: 41 },
      { id: 18, name: "Larissa Freitas", avatar: "https://i.pravatar.cc/150?img=48", boxsBuyed: 35 },
      { id: 19, name: "Gabriel Nunes", avatar: "https://i.pravatar.cc/150?img=13", boxsBuyed: 28 },
      { id: 20, name: "Isabella Cardoso", avatar: "https://i.pravatar.cc/150?img=43", boxsBuyed: 19 },
    ].map((player, index) => ({ ...player, rank: index + 1 }));

    const data = await fetchNui<RankPlayer[]>({
      path: "get:ranking:byPeriod",
      payload: { period },
      mockData,
    });

    if (data) {
      set({ rank: data, selectedPeriod: period });
    }
  },
}));

// ── SVG Icons ────────────────────────────────────────────────────────────────

const RankBadgeIcon = memo(() => (
  <svg
    width="2.875rem"
    height="2.875rem"
    viewBox="0 0 46 46"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <path
      d="M18.5811 5.48047C21.0218 3.03975 24.9782 3.03975 27.4189 5.48047L40.5195 18.5811C42.9603 21.0218 42.9603 24.9782 40.5195 27.4189L27.4189 40.5195C24.9782 42.9603 21.0218 42.9603 18.5811 40.5195L5.48047 27.4189C3.03975 24.9782 3.03975 21.0218 5.48047 18.5811L18.5811 5.48047Z"
      stroke="rgb(var(--primaryColor))"
      strokeWidth="1.5"
    />
    <path
      d="M20.1716 8.82843C21.7337 7.26633 24.2663 7.26633 25.8284 8.82843L37.1716 20.1716C38.7337 21.7337 38.7337 24.2663 37.1716 25.8284L25.8284 37.1716C24.2663 38.7337 21.7337 38.7337 20.1716 37.1716L8.82843 25.8284C7.26633 24.2663 7.26633 21.7337 8.82843 20.1716L20.1716 8.82843Z"
      fill="url(#paint0_linear_651_681)"
      fillOpacity="0.7"
    />
    <path
      d="M20.1716 8.82843C21.7337 7.26633 24.2663 7.26633 25.8284 8.82843L37.1716 20.1716C38.7337 21.7337 38.7337 24.2663 37.1716 25.8284L25.8284 37.1716C24.2663 38.7337 21.7337 38.7337 20.1716 37.1716L8.82843 25.8284C7.26633 24.2663 7.26633 21.7337 8.82843 20.1716L20.1716 8.82843Z"
      fill="url(#paint1_linear_651_681)"
    />
    <path
      d="M20.4189 9.07617C21.8444 7.65076 24.1556 7.65076 25.5811 9.07617L36.9238 20.4189C38.3492 21.8444 38.3492 24.1556 36.9238 25.5811L25.5811 36.9238C24.1556 38.3492 21.8444 38.3492 20.4189 36.9238L9.07617 25.5811C7.65076 24.1556 7.65076 21.8444 9.07617 20.4189L20.4189 9.07617Z"
      stroke="rgb(var(--primaryColor))"
      strokeOpacity="0.6"
      strokeWidth="0.7"
    />
    <path
      d="M25.6077 23.6675L26.744 30.062C26.7567 30.1373 26.7462 30.2147 26.7137 30.2838C26.6813 30.3529 26.6285 30.4105 26.5624 30.4488C26.4964 30.4872 26.4202 30.5044 26.3441 30.4983C26.268 30.4921 26.1956 30.4629 26.1365 30.4145L23.4515 28.3992C23.3219 28.3024 23.1644 28.2501 23.0026 28.2501C22.8408 28.2501 22.6834 28.3024 22.5537 28.3992L19.8642 30.4137C19.8052 30.4621 19.7329 30.4913 19.6569 30.4974C19.5808 30.5036 19.5048 30.4864 19.4387 30.4482C19.3727 30.4099 19.32 30.3525 19.2874 30.2835C19.2549 30.2145 19.2442 30.1372 19.2567 30.062L20.3922 23.6675M27.5 20C27.5 22.4853 25.4853 24.5 23 24.5C20.5147 24.5 18.5 22.4853 18.5 20C18.5 17.5147 20.5147 15.5 23 15.5C25.4853 15.5 27.5 17.5147 27.5 20Z"
      stroke="white"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    <defs>
      <linearGradient
        id="paint0_linear_651_681"
        x1="23"
        y1="6"
        x2="23"
        y2="40"
        gradientUnits="userSpaceOnUse"
      >
        <stop stopColor="#363636" />
        <stop offset="1" stopColor="#1D1D1D" />
      </linearGradient>
      <linearGradient
        id="paint1_linear_651_681"
        x1="23.9444"
        y1="-8.16667"
        x2="60.3056"
        y2="41.4167"
        gradientUnits="userSpaceOnUse"
      >
        <stop stopColor="rgb(var(--primaryColor))" />
        <stop offset="0.7" stopColor="rgb(var(--primaryColor))" stopOpacity="0" />
      </linearGradient>
    </defs>
  </svg>
));

const MedalIcon = memo(() => (
  <svg
    width="1rem"
    height="1rem"
    viewBox="0 0 16 16"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <path
      d="M7.99902 0.666016C10.5763 0.666016 12.6659 2.75582 12.666 5.33301C12.666 6.74689 12.0362 8.01326 11.043 8.86914L11.9834 14.1611L11.9844 14.167C12.0181 14.3675 11.9896 14.5738 11.9033 14.7578C11.8168 14.942 11.676 15.0961 11.5 15.1982C11.324 15.3003 11.1208 15.3464 10.918 15.3301C10.7241 15.3144 10.5401 15.2409 10.3867 15.1221V15.124L8 13.333L5.61133 15.124L5.61035 15.1221C5.4573 15.2403 5.27421 15.3135 5.08105 15.3291C4.8784 15.3455 4.67499 15.3001 4.49902 15.1982C4.32314 15.0964 4.18243 14.9426 4.0957 14.7588C4.00908 14.575 3.98036 14.3684 4.01367 14.168L4.01465 14.1611L4.9541 8.86914C3.96116 8.01327 3.33203 6.74662 3.33203 5.33301C3.3322 2.75582 5.4218 0.666016 7.99902 0.666016ZM5.47559 13.5586L7.20215 12.2666L7.20312 12.2656C7.4335 12.0935 7.71341 12.001 8.00098 12.001C8.28851 12.001 8.56844 12.0936 8.79883 12.2656L8.80078 12.2666L10.5215 13.5576L9.82324 9.62988C9.26281 9.86815 8.64637 10 7.99902 10C7.35091 10 6.73382 9.86772 6.17285 9.62891L5.47559 13.5586ZM7.99902 2C6.15818 2 4.66618 3.4922 4.66602 5.33301C4.66602 7.17396 6.15807 8.66602 7.99902 8.66602C9.83997 8.66602 11.332 7.17396 11.332 5.33301C11.3319 3.4922 9.83987 2 7.99902 2Z"
      fill="rgb(var(--primaryColor))"
      fillOpacity="0.6"
    />
  </svg>
));

const ChestIcon = memo(({ fill }: { fill?: string }) => (
  <svg
    width="1.0625rem"
    height="1.0625rem"
    viewBox="0 0 17 17"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <path
      d="M3.11824 10.5522C3.11824 9.64627 3.11451 8.74032 3.12197 7.83808C3.12197 7.70237 3.08094 7.64002 2.94664 7.61434C2.80114 7.585 2.65938 7.54099 2.51762 7.49697C2.18933 7.39795 2.00653 7.15221 2.0028 6.81478C1.99907 6.22794 1.99907 5.6411 2.0028 5.05427C2.0028 4.69849 2.19679 4.45642 2.54746 4.36106C3.2712 4.163 3.98748 3.96495 4.70748 3.78156C4.87908 3.73755 4.93131 3.66052 4.9425 3.49914C4.97235 3.09569 5.02458 2.69591 5.05442 2.29246C5.09919 1.66894 5.74831 1.26916 6.34521 1.65427C6.88987 2.00637 7.46438 2.31079 8.02397 2.64089C8.13216 2.70325 8.22915 2.71058 8.35226 2.69958C8.65444 2.6739 8.96035 2.68124 9.26626 2.6849C9.51996 2.68857 9.77359 2.71425 10.0273 2.71791C10.0833 2.71791 10.1467 2.68857 10.1952 2.65923C10.7809 2.3218 11.3703 1.99904 11.9411 1.6396C12.5082 1.28016 13.1498 1.65794 13.2021 2.28146C13.2431 2.74359 13.2878 3.20572 13.3438 3.66786C13.3512 3.72654 13.4184 3.80723 13.4744 3.82557C14.0451 3.99795 14.6159 4.15933 15.1905 4.32439C15.2091 4.32805 15.2277 4.33539 15.2464 4.33539C15.8321 4.41974 16 4.6068 16 5.18997C16 5.72179 16 6.25361 16 6.78543C16 7.15588 15.8171 7.39061 15.4553 7.50064C15.2725 7.55566 15.0151 7.56299 14.9256 7.68403C14.8285 7.81607 14.8845 8.05814 14.8845 8.25253C14.8845 9.89931 14.8845 11.5425 14.8845 13.1893C14.8845 13.6184 14.7279 13.8312 14.3137 13.9559C12.6798 14.451 11.0458 14.9425 9.41551 15.4376C9.14691 15.5183 8.87828 15.522 8.60967 15.4413C6.95329 14.9425 5.29691 14.44 3.63679 13.9375C3.29358 13.8348 3.11824 13.5964 3.11824 13.2407C3.11824 12.3494 3.11824 11.4508 3.11824 10.5522ZM14.1683 7.87475C14.1085 7.88576 14.0638 7.89309 14.0265 7.9041C12.497 8.32955 10.9674 8.75502 9.43413 9.17316C9.29987 9.20978 9.29609 9.27952 9.29609 9.38587C9.29987 10.3651 9.29609 11.3408 9.29609 12.3201C9.29609 12.6098 9.17673 12.7491 8.93423 12.7455C8.69921 12.7419 8.57983 12.6061 8.57983 12.3274C8.57983 11.88 8.57983 11.4361 8.57983 10.9886C8.57983 10.3908 8.57983 9.79295 8.57983 9.1768C7.00552 8.74032 5.43494 8.30388 3.84571 7.86375C3.84571 7.94811 3.84571 8.00679 3.84571 8.06548C3.84571 9.73428 3.84944 11.4031 3.84198 13.0719C3.84198 13.2297 3.89794 13.2774 4.03597 13.3213C5.60655 13.7908 7.16966 14.2713 8.74024 14.7334C8.90066 14.7811 9.1021 14.7848 9.26255 14.7371C10.8406 14.2713 12.4111 13.7908 13.9855 13.3213C14.1272 13.2774 14.1757 13.2223 14.1757 13.0719C14.1683 11.4031 14.172 9.73428 14.172 8.06548C14.1683 8.00679 14.1683 7.94444 14.1683 7.87475ZM15.2688 5.06893C15.183 5.09094 15.1121 5.10928 15.0412 5.12762C13.1535 5.65944 11.2696 6.19493 9.38562 6.73042C9.13942 6.80011 8.90066 6.80744 8.65071 6.73776C6.96076 6.25728 5.27453 5.78048 3.58457 5.30367C3.30478 5.22298 3.02498 5.14962 2.7228 5.06527C2.7228 5.14595 2.7228 5.20831 2.7228 5.26699C2.7228 5.71813 2.73026 6.17292 2.71907 6.62406C2.71534 6.77443 2.76011 6.83311 2.90933 6.87346C4.67017 7.35394 6.43101 7.82707 8.18066 8.34055C8.74771 8.50926 9.26255 8.50562 9.82588 8.34055C11.5755 7.82707 13.3363 7.35394 15.0972 6.87346C15.2315 6.83678 15.2874 6.78543 15.2837 6.63872C15.2725 6.17292 15.28 5.71079 15.28 5.24499C15.28 5.18997 15.2725 5.13862 15.2688 5.06893ZM4.05835 4.69116C4.1852 4.7315 4.25608 4.75351 4.32695 4.77551C5.78935 5.18997 7.25174 5.60076 8.7104 6.02255C8.90812 6.08123 9.09468 6.08123 9.29238 6.02255C10.7511 5.60442 12.2172 5.18997 13.6758 4.77551C13.7355 4.75718 13.7952 4.73517 13.9034 4.69849C13.6796 4.63614 13.5154 4.58113 13.3475 4.54445C13.3027 4.53344 13.2356 4.55178 13.2058 4.58113C13.0379 4.74251 12.8401 4.79018 12.6126 4.79018C10.2773 4.78652 7.93817 4.78652 5.60282 4.79018C5.36033 4.79018 5.17007 4.70949 5.01338 4.52977C4.98354 4.49677 4.90893 4.47109 4.86416 4.47843C4.61048 4.53711 4.36053 4.61047 4.05835 4.69116ZM10.5347 4.07131C11.2584 4.07131 11.9448 4.07131 12.6536 4.07131C12.579 3.44412 12.5604 2.82428 12.4485 2.18242C11.7993 2.5602 11.2024 2.90497 10.6055 3.25707C10.572 3.27541 10.5384 3.31942 10.5347 3.35243C10.5309 3.58717 10.5347 3.82557 10.5347 4.07131ZM5.61028 4.07131C6.32282 4.07131 7.01298 4.07131 7.72552 4.07131C7.72552 3.84758 7.73298 3.63485 7.7218 3.42579C7.71807 3.3561 7.66583 3.26807 7.60987 3.2314C7.10252 2.92698 6.5877 2.62989 6.07661 2.3328C6.00572 2.28879 5.93111 2.25211 5.80054 2.18242C5.73339 2.83161 5.6737 3.44412 5.61028 4.07131ZM8.46045 4.06764C8.91932 4.06764 9.35951 4.06764 9.79599 4.06764C9.79599 3.84024 9.79599 3.62384 9.79599 3.40745C9.3446 3.40745 8.90439 3.40745 8.46045 3.40745C8.46045 3.63485 8.46045 3.84391 8.46045 4.06764Z"
      fill={fill || "#FFD400"}
    />
  </svg>
));

const CrownIcon = memo(({ fill }: { fill?: string }) => (
  <svg
    width="1rem"
    height=".8125rem"
    viewBox="0 0 16 13"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
  >
    <path
      d="M13.2 11.375H2.8C2.58 11.375 2.4 11.5578 2.4 11.7812V12.5938C2.4 12.8172 2.58 13 2.8 13H13.2C13.42 13 13.6 12.8172 13.6 12.5938V11.7812C13.6 11.5578 13.42 11.375 13.2 11.375ZM14.8 3.25C14.1375 3.25 13.6 3.7959 13.6 4.46875C13.6 4.64902 13.64 4.8166 13.71 4.97148L11.9 6.07344C11.515 6.30703 11.0175 6.175 10.795 5.77891L8.7575 2.1582C9.025 1.93477 9.2 1.59961 9.2 1.21875C9.2 0.545898 8.6625 0 8 0C7.3375 0 6.8 0.545898 6.8 1.21875C6.8 1.59961 6.975 1.93477 7.2425 2.1582L5.205 5.77891C4.9825 6.175 4.4825 6.30703 4.1 6.07344L2.2925 4.97148C2.36 4.81914 2.4025 4.64902 2.4025 4.46875C2.4025 3.7959 1.865 3.25 1.2025 3.25C0.54 3.25 0 3.7959 0 4.46875C0 5.1416 0.5375 5.6875 1.2 5.6875C1.265 5.6875 1.33 5.67734 1.3925 5.66719L3.2 10.5625H12.8L14.6075 5.66719C14.67 5.67734 14.735 5.6875 14.8 5.6875C15.4625 5.6875 16 5.1416 16 4.46875C16 3.7959 15.4625 3.25 14.8 3.25Z"
      fill={fill || "white"}
    />
  </svg>
));

// ── Sub-components ───────────────────────────────────────────────────────────

function Header() {
  return (
    <header className="mb-8 flex flex-col items-center">
      <div className="flex items-center gap-2.5">
        <div
          className="-scale-x-100 h-[.0625rem] w-[3.75rem]"
          style={{
            background:
              "linear-gradient(90deg, rgba(var(--primaryColor), 0.3) 0%, rgba(var(--primaryColor), 0) 100%)",
          }}
        />
        <RankBadgeIcon />
        <div
          className="h-[.0625rem] w-[3.75rem]"
          style={{
            background:
              "linear-gradient(90deg, rgba(var(--primaryColor), 0.3) 0%, rgba(var(--primaryColor), 0) 100%)",
          }}
        />
      </div>

      <div className="mt-2.5 flex items-center gap-2">
        <div
          className="size-1 rounded-full bg-primaryColor"
          style={{
            boxShadow:
              "0rem 0rem .25rem 0rem rgba(var(--primaryColor), 1),0rem 0rem .625rem 0rem rgba(var(--primaryColor), 1)",
          }}
        />
        <span className="font-semibold text-[1.1875rem] text-primaryColor">
          <span className="text-white">Ranking </span>
          Compradores
        </span>
        <div
          className="size-1 rounded-full bg-primaryColor"
          style={{
            boxShadow:
              "0rem 0rem .25rem 0rem rgba(var(--primaryColor), 1),0rem 0rem .625rem 0rem rgba(var(--primaryColor), 1)",
          }}
        />
      </div>

      <span className="mt-1 text-[#ADADAD] text-xs">
        Acompanhe quem mais comprou
      </span>
    </header>
  );
}

function PeriodButton({ label, period }: { label: string; period: Period }) {
  const { selectedPeriod, setSelectedPeriod } = useRankingStore(
    useShallow((state) => ({
      selectedPeriod: state.selectedPeriod,
      setSelectedPeriod: state.setSelectedPeriod,
    })),
  );

  return (
    <button
      type="button"
      className={cn(
        "group h-[2.125rem] w-[5.875rem] rounded-md border border-white/[.16] border-solid p-[.1875rem] transition-all duration-300 hover:border-primaryColor",
        { "border-primaryColor": selectedPeriod === period },
      )}
      onClick={() => setSelectedPeriod(period)}
    >
      <div
        className={cn(
          "relative flex size-full items-center justify-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/[.08] transition-all duration-300 hover:border-primaryColor",
          { "border-primaryColor bg-transparent": selectedPeriod === period },
        )}
      >
        <span
          className={cn(
            "pointer-events-none relative z-10 font-semibold text-[.8125rem] text-white/80 transition-all duration-300 hover:border-primaryColor group-hover:text-white",
            { "text-white": selectedPeriod === period },
          )}
        >
          {label}
        </span>
        <div
          className={cn(
            "pointer-events-none absolute inset-0 opacity-0 transition-all duration-300 group-hover:opacity-100",
            { "opacity-100": selectedPeriod === period },
          )}
          style={{
            background:
              "linear-gradient(134.74deg, rgb(var(--primaryColor)) -47.65%, rgba(var(--primaryColor), 0.5) 122.65%)",
          }}
        />
      </div>
    </button>
  );
}

function PeriodFilter() {
  return (
    <div className="mb-8 flex items-center gap-2">
      <PeriodButton label="Geral" period="all" />
      <PeriodButton label="Semanal" period="weekly" />
      <PeriodButton label="Mensal" period="montlhy" />
    </div>
  );
}

function RankingRow({ avatar, boxsBuyed, id, name, rank }: RankPlayer) {
  const { imageUrl, isImageValid } = useImageValidation(avatar);

  return (
    <div className="min-h-16 w-[calc(100%-.5rem-.25rem)] rounded-lg border border-white/[.16] border-solid p-1">
      <div className="flex size-full items-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/10 px-2">
        {/* Rank badge */}
        <span className="w-[6.25rem] font-bold text-[#adadad]/50 text-[.8125rem] uppercase">
          <div
            className="flex size-8 items-center justify-center rounded-[.4375rem] border border-solid p-0.5"
            style={{
              borderColor: rank >= 1 && rank <= 3 ? RANK_COLORS[rank] : "#737373",
            }}
          >
            <div
              className={cn(
                "flex size-full items-center justify-center rounded-[.3125rem] font-bold text-white text-xs",
                { "text-black": rank === 2 || rank === 3 },
              )}
              style={{
                background:
                  rank === 1 || rank === 2
                    ? "linear-gradient(134.74deg, #C0C0C0 -47.65%, rgba(192, 192, 192, 0.9) 122.65%)"
                    : rank === 3
                      ? "linear-gradient(134.74deg, #CD7F32 -47.65%, rgba(205, 127, 50, 0.9) 122.65%)"
                      : "linear-gradient(134.74deg, rgba(115, 115, 115, 0.1) -47.65%, rgba(115, 115, 115, 0.09) 122.65%)",
              }}
            >
              {rank === 1 ? <CrownIcon fill="#000" /> : rank}
            </div>
          </div>
        </span>

        {/* Player info */}
        <span className="flex w-[51.5rem] items-center gap-2.5">
          <img
            src={isImageValid ? imageUrl : fallbackAvatar}
            alt=""
            className="size-8 rounded-full border border-solid"
            style={{
              borderColor: rank >= 1 && rank <= 3 ? RANK_COLORS[rank] : " #737373",
            }}
          />
          <div className="flex flex-col items-start">
            <h1 className="font-semibold text-sm">{name}</h1>
            <span className="text-[#adadad] text-xs">#{id}</span>
          </div>
        </span>

        {/* Boxes bought */}
        <span className="flex w-[8.75rem] items-center justify-center gap-1.5 font-semibold text-[#f2f2f2] text-[.9375rem]">
          <ChestIcon fill={rank >= 1 && rank <= 3 ? RANK_COLORS[rank] : " #737373"} />
          {boxsBuyed}
        </span>
      </div>
    </div>
  );
}

function FullRanking() {
  const rank = useRankingStore((state) => state.rank);

  return (
    <div className="mt-6 flex w-[68.75rem] flex-col">
      {/* Section header */}
      <header className="flex w-[calc(100%-.5rem-.25rem)] items-center gap-1">
        <div
          className="-scale-x-100 h-[.0625rem] w-8"
          style={{
            background:
              "linear-gradient(90deg, rgba(var(--primaryColor), 0.3) 0%, rgba(var(--primaryColor), 0) 100%)",
          }}
        />
        <div className="flex items-center gap-2 font-semibold text-sm">
          <MedalIcon />
          Ranking Completo
        </div>
        <div
          className="h-[.0625rem] w-[48.625rem]"
          style={{
            background:
              "linear-gradient(90deg, rgba(var(--primaryColor), 0.3) 0%, rgba(var(--primaryColor), 0) 100%)",
          }}
        />
        <div className="flex items-center gap-1.5 font-medium text-[#ADADAD] text-xs">
          <svg
            width=".875rem"
            height=".875rem"
            viewBox="0 0 14 14"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M6.99935 12.8333C10.221 12.8333 12.8327 10.2216 12.8327 6.99996C12.8327 3.7783 10.221 1.16663 6.99935 1.16663C3.77769 1.16663 1.16602 3.7783 1.16602 6.99996C1.16602 10.2216 3.77769 12.8333 6.99935 12.8333Z"
              stroke="#F2F2F2"
              strokeOpacity="0.3"
              strokeWidth="1.16667"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M7 10.5C8.933 10.5 10.5 8.933 10.5 7C10.5 5.067 8.933 3.5 7 3.5C5.067 3.5 3.5 5.067 3.5 7C3.5 8.933 5.067 10.5 7 10.5Z"
              stroke="#F2F2F2"
              strokeOpacity="0.3"
              strokeWidth="1.16667"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path
              d="M7.00065 8.16671C7.64498 8.16671 8.16732 7.64437 8.16732 7.00004C8.16732 6.35571 7.64498 5.83337 7.00065 5.83337C6.35632 5.83337 5.83398 6.35571 5.83398 7.00004C5.83398 7.64437 6.35632 8.16671 7.00065 8.16671Z"
              stroke="#F2F2F2"
              strokeOpacity="0.3"
              strokeWidth="1.16667"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
          {rank.length} jogadores
        </div>
      </header>

      {/* Table header */}
      <div className="mt-4 mb-2 flex h-8 w-[calc(100%-.5rem-.5rem)] items-center rounded-md border border-white/[.16] border-solid px-3">
        <span className="w-[6.25rem] font-bold text-[#adadad]/50 text-[.8125rem] uppercase">
          #
        </span>
        <span className="w-[51.5rem] font-bold text-[#adadad]/50 text-[.8125rem] uppercase">
          Jogador
        </span>
        <span className="w-[8.75rem] text-center font-bold text-[#adadad]/50 text-[.8125rem] uppercase">
          Caixas compradas
        </span>
      </div>

      {/* Scrollable list */}
      <div className="scrollbar-custom flex h-[23.75rem] w-full flex-col gap-2 overflow-auto">
        {rank?.length > 0 &&
          rank.map((player) => (
            <RankingRow key={player.rank} {...player} />
          ))}
      </div>
    </div>
  );
}

function TopPlayerCard({ avatar, boxsBuyed, id, name, rank }: RankPlayer) {
  const { imageUrl, isImageValid } = useImageValidation(avatar);

  return (
    <div
      className={cn(
        "h-[16.0625rem] w-[11.4375rem] rounded-[.625rem] border border-white/[.14] border-solid p-1",
        { "self-start": rank === 1 },
      )}
    >
      <div
        className="flex size-full flex-col items-center rounded-md border-b-2 border-solid py-4 bg-blend-multiply"
        style={{
          borderColor: RANK_COLORS[rank],
          background: `linear-gradient(0deg, rgba(12, 12, 12, 0.24), rgba(12, 12, 12, 0.24)),linear-gradient(180deg, ${hexToRgba(RANK_COLORS[rank], 0.32)} -17.86%, ${hexToRgba(RANK_COLORS[rank], 0)} 53.57%),radial-gradient(84.97% 84.97% at 42.96% -53.27%, rgba(255, 255, 255, 0.11) 0%, rgba(153, 153, 153, 0) 86.08%)`,
        }}
      >
        {/* Crown badge */}
        <div className="flex size-8 items-center justify-center rounded-md border border-white/[.24] border-solid p-[.1875rem]">
          <div className="flex size-full items-center justify-center rounded-[.3125rem] border border-white/[.06] border-solid bg-white/30">
            <CrownIcon fill="#fff" />
          </div>
        </div>

        {/* Avatar */}
        <img
          src={isImageValid ? imageUrl : fallbackAvatar}
          alt=""
          className="mt-2 mb-2 size-[4.75rem] rounded-full border border-solid"
          style={{ borderColor: RANK_COLORS[rank] }}
        />

        {/* Player info */}
        <span className="font-bold text-sm text-white uppercase">{name}</span>
        <span className="mt-1 text-[#adadad] text-[.6875rem]">#{id}</span>

        {/* Divider */}
        <div
          className="mt-4 h-[.0625rem] w-[8.125rem]"
          style={{
            background:
              "linear-gradient(90deg, rgba(242, 242, 242, 0) 0%, rgba(242, 242, 242, 0.1) 50%, rgba(242, 242, 242, 0) 100%)",
          }}
        />

        {/* Boxes count */}
        <div className="mt-auto flex items-center gap-1.5">
          <ChestIcon fill={RANK_COLORS[rank]} />
          <h1 className="font-semibold text-[#f2f2f2] text-[.9375rem]">
            {boxsBuyed}
          </h1>
          <span className="text-[#adadad] text-xs">Caixas</span>
        </div>
      </div>
    </div>
  );
}

function TopPlayers() {
  const rank = useRankingStore((state) => state.rank);

  const first = useMemo(() => rank.find((p) => p.rank === 1), [rank]);
  const second = useMemo(() => rank.find((p) => p.rank === 2), [rank]);
  const third = useMemo(() => rank.find((p) => p.rank === 3), [rank]);

  return (
    <div className="relative flex h-[17.5625rem] min-w-[68rem] items-end justify-center gap-4">
      {!first && !second && !third && (
        <div className="-translate-x-1/2 -translate-y-1/2 absolute top-1/2 left-1/2 font-bold text-white/80 text-xl">
          Não há jogadores no Top 3.
        </div>
      )}
      {second && <TopPlayerCard {...second} />}
      {first && <TopPlayerCard {...first} />}
      {third && <TopPlayerCard {...third} />}
    </div>
  );
}

// ── Main Page ────────────────────────────────────────────────────────────────

export function Ranking() {
  const visible = useVisibility((state) => state.visible);
  const setSelectedPeriod = useRankingStore((state) => state.setSelectedPeriod);

  useEffect(() => {
    if (visible) {
      setSelectedPeriod("all");
    }
  }, [visible, setSelectedPeriod]);

  return (
    <div className="flex h-full w-full flex-col items-center justify-center">
      <Header />
      <PeriodFilter />
      <TopPlayers />
      <FullRanking />
    </div>
  );
}
