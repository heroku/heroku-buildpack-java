require "tmpdir"
require "open3"
require "securerandom"
require "docker"

module Rapier

  class Runner
    attr_reader :default_buildpacks

    def initialize(fixture_directory, default_builder, default_buildpacks: [])
      @fixture_directory = fixture_directory
      @default_builder = default_builder
      @default_buildpacks = default_buildpacks
    end

    def app_dir_from_fixture(name)
      Dir.mktmpdir do |temp_dir|
        FileUtils.copy_entry(File.join(@fixture_directory, name), temp_dir)
        yield temp_dir
      end
    end

    def pack_build(app_dir, image_name: nil, buildpacks: [], build_env: {}, builder: nil, exception_on_failure: true)
      image_name = "cnb_test_" + SecureRandom.hex(10) if image_name == nil
      buildpacks = @default_buildpacks if buildpacks.empty?
      builder = @default_builder if builder == nil

      buildpack_argument = "--buildpack " + buildpacks.map { |bp| bp == :this ? "." : bp }.join(",")
      builder_argument = "-B #{builder}"
      env_arguments = build_env.keys.map { |key| "--env #{key}=#{build_env[key]}" }.join(" ")
      pack_command = "pack build #{image_name} #{builder_argument} --path #{app_dir} #{env_arguments} #{buildpack_argument}"

      pack_stdout, pack_stderr, pack_status = Open3.capture3(pack_command)

      if pack_status == 0
        image = Docker::Image.get(image_name)
      else
        image = nil
        if exception_on_failure
          raise "Pack exited with status code #{pack_status}, indicating an error and failed build!\nstderr: #{pack_stderr}"
        end
      end

      begin
        yield PackBuildResult.new(pack_stdout, pack_stderr, pack_status, image, image_name)
      ensure
        image.remove(:force => true) unless image == nil rescue nil
      end
    end
  end

  class PackBuildResult
    attr_reader :stdout, :stderr, :status, :image, :image_name

    def initialize(stdout, stderr, status, image, image_name)
      @stdout = stdout
      @stderr = stderr
      @status = status
      @image = image
      @image_name = image_name
      freeze
    end

    def build_success?()
      @status == 0
    end

    def start_container(expose_ports: [])
      expose_ports = [expose_ports] unless expose_ports.kind_of?(Array)

      config = {
          "Image" => @image.id,
          "ExposedPorts" => {},
          "HostConfig" => {
              "PortBindings" => {}
          }
      }

      expose_ports.each do |port|
        config["ExposedPorts"]["#{port}/tcp"] = {}
        # If we do not specify a port, Docker will grab a random unused one:
        config["HostConfig"]["PortBindings"]["#{port}/tcp"] = [{"HostPort" => ""}]
      end

      container = Docker::Container.create(config)
      container.start

      begin
        yield Container.new(container)
      ensure
        container.delete(:force => true)
      end
    end
  end

  class Container
    def initialize(container)
      @container = container
    end

    def get_host_port(port)
      @container.json["NetworkSettings"]["Ports"]["#{port}/tcp"][0]["HostPort"]
    end

    def bash_exec(cmd, exception_on_failure: true)
      result = @container.exec(["bash", "-c", cmd])
      bash_exec_result = BashExecResult.new(result[0][0], result[1], result[2])

      if bash_exec_result.status != 0 and exception_on_failure
        raise "bash_exec(#{cmd}) failed: #{bash_exec_result.status}\nstderr: #{bash_exec_result.stderr}"
      end

      bash_exec_result
    end

    def contains_file(path)
      bash_exec("[[ -f '#{path}' ]]").status == 0
    end

    def get_file_contents(path)
      bash_exec("cat '#{path}'").stdout
    end

    class BashExecResult
      attr_reader :stdout, :stderr, :status

      def initialize(stdout, stderr, status)
        @stdout = stdout
        @stderr = stderr
        @status = status
        freeze
      end
    end
  end
end
