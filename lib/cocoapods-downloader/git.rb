module Pod
  module Downloader

    # Concreted Downloader class that provides support for specifications with
    # git sources.
    #
    class Git < Base

      def self.options
        [:commit, :tag, :branch, :submodules]
      end

      def options_specific?
        !options[:commit].nil? || !options[:tag].nil?
      end

      def checkout_options
        Dir.chdir(target_path) do
          options = {}
          options[:git] = url
          options[:commit] = `git rev-parse HEAD`.chomp
          options
        end
      end

      private

      executable :git

      def download!
        create_cache if use_cache? && !cache_exist?
        if options[:tag]
          download_tag
        elsif options[:branch]
          download_branch
        elsif options[:commit]
          download_commit
        else
          download_head!
        end
        Dir.chdir(target_path) { git! "submodule update --init"  } if options[:submodules]
      end

      # @return [void] Checkouts the HEAD of the git source in the destination
      #         path.
      #
      def download_head!
        update_cache if use_cache?
        clone(clone_url, target_path)
        Dir.chdir(target_path) { git! "submodule update --init"  } if options[:submodules]
      end

      #--------------------------------------#

      # @!group Download implementations

      # @return [Pathname] The clone URL, which resolves to the cache path.
      #
      def clone_url
        use_cache? ? cache_path : url
      end

      # @return [void] Convenience method to perform clones operations.
      #
      def clone(from, to)
        ui_sub_action("Cloning to Pods folder") do
          git! %Q|clone "#{from}" "#{to}"|
        end
      end

      # @return [void] Checkouts a specific tag of the git source in the
      #         destination path.
      #
      # @note   Tags trigger a cache update unless aggressive cache is
      #         specified.
      #
      # @note   Git fetch and checkout output to standard error and thus they
      #         are redirected to stdout.
      #
      def download_tag
        if use_cache?
          if aggressive_cache?
            ensure_ref_exists(options[:tag])
          else
            update_cache
          end
        end

        Dir.chdir(target_path) do
          git! "init"
          git! "remote add origin '#{clone_url}'"
          git! "fetch origin tags/#{options[:tag]} 2>&1"
          git! "reset --hard FETCH_HEAD"
          git! "checkout -b activated-pod-commit 2>&1"
        end
      end

      # @return [void] Checkouts a specific commit of the git source in the
      #         destination path.
      #
      # @note   Git checkouts output to standard error and thus it is
      #         redirected to stdout.
      #
      def download_commit
        ensure_ref_exists(options[:commit]) if use_cache?
        clone(clone_url, target_path)
        Dir.chdir(target_path) do
          git! "checkout -b activated-pod-commit #{options[:commit]} 2>&1"
        end
      end

      # @return [void] Checkouts the HEAD of a specific branch of the git
      #         source in the destination path.
      #
      # @note   Git checkouts output to standard error and thus it is
      #         redirected to stdout.
      #
      def download_branch
        update_cache if use_cache?
        clone(clone_url, target_path)
        Dir.chdir(target_path) do
          git! "remote add upstream '#{@url}'" # we need to add the original url, not the cache url
          git! "fetch -q upstream" # refresh the branches
          git! "checkout --track -b activated-pod-commit upstream/#{options[:branch]} 2>&1" # create a new tracking branch
          ui_message("Just downloaded and checked out branch: #{options[:branch]} from upstream #{clone_url}")
        end
      end

      #--------------------------------------#

      # @!group Checking references

      # @return [Bool] Whether a reference (commit SHA or tag)
      #
      def ref_exists?(ref)
        if cache_exist?
          Dir.chdir(cache_path) { git "rev-list --max-count=1 #{ref}" }
          $? == 0
        else
          false
        end
      end

      # @return [void] Checks if a reference exists in the cache and updates
      #         only if necessary.
      #
      # @raise If after the update the reference can't be found.
      #
      def ensure_ref_exists(ref)
        return if ref_exists?(ref)
        update_cache
        raise DownloaderError, "Cache unable to find git reference `#{ref}' for `#{url}'." unless ref_exists?(ref)
      end

      # @return [Bool] Whether a branch exists in the cache.
      #
      def branch_exists?(branch)
        Dir.chdir(cache_path) { git "branch --all | grep #{branch}$" } # check for remote branch and do suffix matching ($ anchor)
        $? == 0
      end

      # @return [void] Checks if a branch exists in the cache and updates
      #         only if necessary.
      #
      # @raise  If after the update the branch can't be found.
      #
      def ensure_remote_branch_exists(branch)
        return if branch_exists?(branch)
        update_cache
        raise DownloaderError, "Cache unable to find git reference `#{branch}' for `#{url}' (#{$?})." unless branch_exists?(branch)
      end

      #--------------------------------------#

      # @!group Cache

      # @return [Bool] Whether the cache exits.
      #
      # @note   The previous implementation of the cache didn't use a barebone
      #         git repo. This method takes into account this fact and checks
      #         that the cache is actually a barebone repo. If the cache was
      #         not barebone it will be deleted and recreated.
      #
      def cache_exist?
        cache_path.exist? &&
          cache_origin_url(cache_path).to_s == url.to_s &&
          Dir.chdir(cache_path) { git("config core.bare").chomp == "true" }
      end

      # @return [String] The origin URL of the cache with the given directory.
      #
      # @param [String] dir The directory of the cache.
      #
      def cache_origin_url(dir)
        Dir.chdir(dir) { `git config remote.origin.url`.chomp }
      end

      # @return [void] Creates the barebone repo that will serve as the cache
      #         for the current repo.
      #
      def create_cache
        ui_sub_action("Creating cache git repo (#{cache_path})") do
          cache_path.rmtree if cache_path.exist?
          cache_path.mkpath
          git! %Q|clone  --mirror "#{url}" "#{cache_path}"|
        end
      end

      # @return [void] Updates the barebone repo used as a cache against its
      #         remote creating it if needed.
      #
      def update_cache
        if cache_exist?
          ui_sub_action("Updating cache git repo (#{cache_path})") do
            Dir.chdir(cache_path) { git! "remote update" }
          end
        else
          create_cache
        end
      end
    end

    #---------------------------------------------------------------------------#

    # Allows to download tarballs from GitHub.
    #
    class GitHub < Git

      require 'open-uri'

      def download_head!
        download_only? ? download_and_extract_tarball('master') : super
      end

      def download_tag
        download_only? ? download_and_extract_tarball(options[:tag]) : super
      end

      def download_commit
        download_only? ? download_and_extract_tarball(options[:commit]) : super
      end

      def download_branch
        download_only? ? download_and_extract_tarball(options[:branch]) : super
      end

      def tarball_url_for(id)
        original_url, username, reponame = *(url.match(/[:\/]([\w\-]+)\/([\w\-]+)\.git/))
        "https://github.com/#{username}/#{reponame}/tarball/#{id}"
      end

      def tmp_path
        target_path + "tarball.tar.gz"
      end

      private

      def download_only?
        @options[:download_only]
      end

      def download_and_extract_tarball(id)
        File.open(tmp_path, "w+") do |tmpfile|
          open tarball_url_for(id) do |archive|
            tmpfile.write Zlib::GzipReader.new(archive).read
          end

          system "tar xf #{tmpfile.path} -C #{target_path} --strip-components 1"
        end
      end
    end
  end
end
