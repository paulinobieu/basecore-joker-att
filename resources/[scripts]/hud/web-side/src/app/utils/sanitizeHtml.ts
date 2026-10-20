import sanitizeHtml from "sanitize-html";

export function sanitizeContent(content: string) {
	return sanitizeHtml(content, {
		allowedTags: ["strong", "b", "p", "br"],
		allowedAttributes: {},
	});
}
