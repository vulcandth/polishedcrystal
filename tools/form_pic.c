#define PROGRAM_NAME "form_pic"
#define USAGE_OPTS "base.2bpp target.2bpp target.2bpp.lzp BasePicLabel"

#include "common.h"

// Each span has a count and a 16-bit destination offset. Bridge gaps of up
// to two unchanged bytes when doing so costs less than starting another span.
static long next_span(const uint8_t *base, const uint8_t *target, long size, long start) {
	long end = start + 1;
	for (long i = end; i < size && i - start < UINT8_MAX && i - end < 3; i++) {
		if (base[i] != target[i]) {
			end = i + 1;
		}
	}
	return end;
}

struct Span {
	unsigned int start, count;
};

int main(int argc, char **argv) {
	if (argc != 5) {
		usage_exit(1);
	}

	long base_size, target_size;
	uint8_t *base = read_u8(argv[1], &base_size);
	uint8_t *target = read_u8(argv[2], &target_size);
	FILE *packed = xfopen(argv[3], 'r');
	long packed_size = xfsize(argv[3], packed);
	xfclose(packed);

	// Marker + far base address + zero span terminator.
	long patch_size = 5;
	bool same_size = base_size == target_size && target_size > 0 && target_size <= 0x1000;
	struct Span *spans = NULL;
	size_t num_spans = 0;
	if (same_size) {
		spans = xmalloc(target_size * sizeof(*spans));
		for (long i = 0; i < target_size;) {
			if (base[i] == target[i]) {
				i++;
				continue;
			}
			long end = next_span(base, target, target_size, i);
			spans[num_spans++] = (struct Span){i, end - i};
			patch_size += 3 + end - i;
			i = end;
		}
	}

	if (same_size && patch_size < packed_size) {
		printf("\tdb $ff\n\tdab %s\n", argv[4]);
		for (size_t n = 0; n < num_spans; n++) {
			struct Span span = spans[n];
			printf("\tdb %u\n\tdw %u\n\tdb ", span.count, span.start);
			for (unsigned int j = 0; j < span.count; j++) {
				printf("$%02x%s", target[span.start + j], j + 1 == span.count ? "\n" : ", ");
			}
		}
		puts("\tdb 0");
	} else {
		printf("\tINCBIN \"%s\"\n", argv[3]);
	}
	free(spans);
	free(target);
	free(base);
	return fflush(stdout) == EOF ? 1 : 0;
}
