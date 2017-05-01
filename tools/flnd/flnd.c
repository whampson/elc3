/**
 *        File: flnd.c
 *      Author: Wes Hampson
 * Description: Flips the endianness of a binary file in chunks of 16-bit words.
 *              (flnd - FLip eNDianness)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PROGRAM_NAME "flnd"

void usage(void)
{
    printf("FLips the eNDianness of a binary file in chunks of 16-bit words.\n\n");
    printf("Usage: %s file [-o outfile]\n", PROGRAM_NAME);
    printf("If `-o' is not specified, the source file will be overwritten.\n");
}

int parse_args(int argc, char *argv[], char **infile, char **outfile)
{
    if (argc == 2)
    {
        *infile = argv[1];
        *outfile = argv[1];
        return 0;
    }

    if (strcmp(argv[2], "-o") != 0)
    {
        usage();
        return 1;
    }
    else
    {
        *infile = argv[1];
        *outfile = argv[3];
    }

    return 0;
}

int main(int argc, char *argv[])
{
    /* Show usage and exit if not enough arguments specifed. */
    if (argc < 2 || argc == 3)
    {
        usage();
        return 1;
    }

    char *infile;
    char *outfile;

    /* Process command-line arguments. */
    int retval = parse_args(argc, argv, &infile, &outfile);
    if (retval != 0)
    {
        return retval;
    }

    /* Open file specified by argument. */
    FILE *f;
    f = fopen(infile, "rb");
    if (f == NULL)
    {
        printf("Unable to open file - %s\n", infile);
        return 2;
    }

    /* Get the file size. */
    fseek(f, 0L, SEEK_END);
    size_t f_siz = ftell(f);
    rewind(f);

    /* Compute buffer size for holding file in memory. */
    /* If file size is not a multiple of 2, add 1 to file size to
       allow for padding of final 16-bit word. */
    size_t buf_siz = (f_siz % 2 == 0) ? f_siz : f_siz + 1;

    /* Read file into memory and close the file. */
    /* Should be OK to read entire file into a single buffer,
       since the files we'll be converting aren't very big. */
    char *buf = (char *) calloc(1, buf_siz);
    fread(buf, sizeof(char), buf_siz, f);
    fclose(f);

    size_t i;
    char *lb;
    char *ub;
    char temp;

    /* Swap the lower and upper bytes of each 16-bit word. */
    for (i = 0; i < buf_siz; i += 2)
    {
        lb = &buf[i];
        ub = &buf[i + 1];

        temp = *lb;
        *lb = *ub;
        *ub = temp;
    }

    /* Open the output file. */
    f = fopen(outfile, "wb");
    if (f == NULL)
    {
        printf("Unable to open file - %s\n", outfile);
        return 2;
    }

    /* Write the endian-flipped buffer to the output file. */
    fwrite(buf, sizeof(char), buf_siz, f);
    fclose(f);

    free(buf);

    return 0;
}