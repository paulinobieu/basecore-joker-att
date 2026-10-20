import anim1 from "@views/assets/animations/1.png";
import anim2 from "@views/assets/animations/2.png";
import anim3 from "@views/assets/animations/3.png";
import anim4 from "@views/assets/animations/4.png";
import anim5 from "@views/assets/animations/5.png";
import anim6 from "@views/assets/animations/6.png";
import anim7 from "@views/assets/animations/7.png";
import anim8 from "@views/assets/animations/8.png";
import anim9 from "@views/assets/animations/9.png";
import anim10 from "@views/assets/animations/10.png";
import anim11 from "@views/assets/animations/11.png";
import anim12 from "@views/assets/animations/12.png";
import anim13 from "@views/assets/animations/13.png";
import anim14 from "@views/assets/animations/14.png";
import anim15 from "@views/assets/animations/15.png";
import anim16 from "@views/assets/animations/16.png";
import anim17 from "@views/assets/animations/17.png";
import anim18 from "@views/assets/animations/18.png";

const ANIMATION_THUMBNAILS: Record<string, string> = {
	"anim-1": anim1,
	"anim-2": anim2,
	"anim-3": anim3,
	"anim-4": anim4,
	"anim-5": anim5,
	"anim-6": anim6,
	"anim-7": anim7,
	"anim-8": anim8,
	"anim-9": anim9,
	"anim-10": anim10,
	"anim-11": anim11,
	"anim-12": anim12,
	"anim-13": anim13,
	"anim-14": anim14,
	"anim-15": anim15,
	"anim-16": anim16,
	"anim-17": anim17,
	"anim-18": anim18,
};

export const getAnimationThumbnailById = (animationId: string): string =>
	ANIMATION_THUMBNAILS[animationId] ?? "";
