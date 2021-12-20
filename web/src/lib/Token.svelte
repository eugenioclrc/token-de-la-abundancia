<script>
  export let token = {}
</script>

  <div class="flex flex-wrap">
    <div class="grow">
      <a href={'/app/token?token='+token.id} class="hover:underline font-bold w-100 block">
        Token id: {token.id}
      </a>
    </div>
    <div class="text-right">Estado 
      {#if token.status == 0}
        <span class="px-2 font-semibold leading-tight text-red-700 border border-red-700 bg-red-100 rounded-sm"> FUEGO </span>
      {:else if token.status == 1}
        <span class="px-2 font-semibold leading-tight text-white border border-blue-600 bg-blue-600 rounded-sm"> AIRE </span>
      {:else if token.status == 2}
        <span class="px-2 font-semibold leading-tight text-green-700 border border-green-100 bg-green-100 rounded-sm"> TIERRA </span>
      {:else if token.status == 3}
        <span class="px-2 font-semibold leading-tight text-blue-700 border border-blue-100 bg-blue-100 rounded-sm"> AGUA </span>
      {/if}
    </div>
    <div class="w-full border-t border-gray-500">
      <blockquote class="relative p-4 text-xl italic border-l-4 bg-neutral-100 bg-opacity-20 text-neutral-600 border-neutral-500 quote">      
        <p class="mb-4">"{token.detail}"</p>
        <cite class="flex items-center">
          <span class="mb-1 text-sm italic font-bold">
            Owner: {String(token.owner).slice(0, 4)}...{String(token.owner).slice(-4)}
          </span>
        </cite>
      </blockquote>
    </div>
  </div>