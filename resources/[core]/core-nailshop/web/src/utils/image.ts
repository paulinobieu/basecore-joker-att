const developerMode = false;

export const getImage = (image: string) => {
  if (developerMode) {
    return `${image}`;
  };

  return `nui://${(window as any).GetParentResourceName()}/web/build/${image}`;
};
