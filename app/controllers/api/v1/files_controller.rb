class Api::V1::FilesController < ApplicationController
    # POST /api/v1/files
    def create
        begin
            mode = validate_and_get_mode(params[:mode])
            file = validate_and_get_file(params[:file])
            filename = file.original_filename
            contents = file.read

            puts "Input: " + contents

            new_contents = contents
            if mode == 'compress'
                new_contents = compress(contents)
                if new_contents.length > contents.length
                    new_contents = contents
                end
            else
                new_contents = decompress(contents)
            end

            puts "Output: " + new_contents

            send_data new_contents, type: 'text/plain', filename: mode + '_' + filename
        rescue ActionController::BadRequest => e
            puts "Error: " + e.message
            render :plain => e.message, :status => 400
        end
    end

    private
        def validate_and_get_mode mode
            if ["compress", "decompress"].include? mode
                return mode
            else
                raise ActionController::BadRequest.new('Query param "mode" is required and can either be compress/decompress.')
            end
        end

        def validate_and_get_file file
            if !file
                raise ActionController::BadRequest.new('No file given as input')
            elsif file.content_type != 'text/plain'
                raise ActionController::BadRequest.new('File content_type should be "text/plain".')
            else
                return file
            end
        end

        def compress str
            new_str = ''
            if str.length > 0
                prev_chr = str[0]
                count = 1
                for pos in 1...str.length
                    if str[pos] == prev_chr
                        count += 1
                    else
                        if count == 1
                            new_str += prev_chr
                        else
                            new_str += count.to_s + prev_chr
                        end
                        prev_chr = str[pos]
                        count = 1
                    end
                end

                if count == 1
                    new_str += prev_chr
                else
                    new_str += count.to_s + prev_chr
                end
            end
            return new_str
        end

        def decompress str
            new_str = ''
            num_str = ''
            for pos in 0...str.length
                if letter(str[pos])
                    if num_str.length > 0
                        new_str += (str[pos] * num_str.to_i)
                    else
                        new_str += str[pos]
                    end
                    num_str = ''
                elsif numeric(str[pos])
                    num_str += str[pos]
                end
            end
            return new_str
        end

        def numeric ch
            ch =~ /[0-9]/
        end

        def letter ch
            ch =~ /[A-Za-z]/
        end
end
