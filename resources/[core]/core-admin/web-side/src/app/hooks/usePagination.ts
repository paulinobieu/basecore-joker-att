import { useEffect, useMemo, useState } from "react";

interface UsePaginationProps {
  totalItems: number;
  itemsPerPage: number;
  resetKey?: unknown;
}

export const usePagination = ({
  totalItems,
  itemsPerPage,
  resetKey,
}: UsePaginationProps) => {
  const [page, setPage] = useState(1);

  const totalPages = useMemo(
    () => Math.max(1, Math.ceil(totalItems / itemsPerPage)),
    [totalItems, itemsPerPage]
  );

  const currentPage = Math.min(Math.max(1, page), totalPages);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;

  useEffect(() => {
    setPage(1);
  }, [resetKey, totalItems]);

  return { currentPage, totalPages, startIndex, endIndex, setPage };
};
